from database_handler import execute_query, create_connection, close_connection,return_data_as_df, return_insert_into_sql_statement_from_df_stg
from datetime import datetime
from logging_handler import show_error_message
from lookups import DESTINATION_SCHEMA,InputTypes,SEASONS,ErrorHandling,WEBSCRAPINGSTAGINGTABLE
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from time import sleep
from datetime import datetime
import pandas as pd
from prehook import return_match_df_from_web,first_time_csv,insert_standings_into_stg


#DONE, TESTED
def create_etl_checkpoint(db_session):
    schema_destination_table = DESTINATION_SCHEMA.DESTINATION_NAME.value
    query = f"""
        CREATE TABLE IF NOT EXISTS {schema_destination_table}.etl_checkpoint
        (
            etl_last_run_index INT,
            ett_last_run_date DATE
        )
        """
    execute_query(db_session, query)


def return_last_match_df_from_web(last_etl_id):
    match_details=[]
    driver = webdriver.Chrome()
    options=Options()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)
    while True:
        url = f'https://www.premierleague.com/match/{last_etl_id}'
        driver.get(url)
        date = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[1]/div[1]'))).text
        date = datetime.strptime(date, '%a %d %b %Y').strftime('%m/%d/%Y')
        home_team= WebDriverWait(driver, 4).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[1]/div[1]/a[2]/span[1]'))).text
        away_team= WebDriverWait(driver, 4).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[3]/div[1]/a[2]/span[1]'))).text
        score=WebDriverWait(driver, 4).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[2]/div[1]'))).text
        try:
            home_score = int(score.split(' -')[0])
            away_score = int(score.split('- ')[1])
        except:
            match_df = pd.DataFrame(match_details,columns=columns)
            driver.quit()
            return last_etl_id,match_df
        stats= WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.XPATH,'//*[@id="mainContent"]/div/section[2]/div[2]/div/div[1]/div/div/ul/li[3]')))
        driver.execute_script("arguments[0].click();",stats)
        sleep(3)
        match_stats_df=pd.read_html(driver.page_source)
        #driver.quit()
        match_stats_df=match_stats_df[-1]
        home_stats = {}
        away_stats = {}
        home_series = match_stats_df[home_team]
        away_series = match_stats_df[away_team]
        stats_series = match_stats_df['Unnamed: 1']
        for row in zip(home_series, stats_series, away_series):
            stat = row[1].replace(' ', '_').lower()
            home_stats[stat] = row[0]
            away_stats[stat] = row[2]
        all_stats = ['possession_%', 'shots_on_target', 'shots', 'touches', 'passes','tackles', 'clearances', 'corners', 'offsides', 'yellow_cards','red_cards', 'fouls_conceded']
        columns = ['match_id','date', 'home_team', 'away_team', 'home_score', 'away_score']
        for stat in all_stats:
            if stat not in home_stats.keys():
                home_stats[stat] = None
                away_stats[stat] = None
            columns.append(f'home_{stat}')
            columns.append(f'away_{stat}')
        match_stats= [last_etl_id,date, home_team, away_team, home_score, away_score, home_stats['possession_%'], away_stats['possession_%'],
                    home_stats['shots_on_target'], away_stats['shots_on_target'], home_stats['shots'], away_stats['shots'],
                    home_stats['touches'], away_stats['touches'], home_stats['passes'], away_stats['passes'],
                    home_stats['tackles'], away_stats['tackles'], home_stats['clearances'], away_stats['clearances'],
                    home_stats['corners'], away_stats['corners'], home_stats['offsides'], away_stats['offsides'],
                    home_stats['yellow_cards'], away_stats['yellow_cards'], home_stats['red_cards'], away_stats['red_cards'],
                    home_stats['fouls_conceded'], away_stats['fouls_conceded']]
        last_etl_id=last_etl_id+1
        match_details.append(match_stats)
    # match_df = pd.DataFrame(match_details,columns=columns)
    # driver.quit()
    # return match_df


def return_etl_last_updated_index(db_session):
    does_etl_index_exists = False
    try:
        query = f"""SELECT match_id FROM {DESTINATION_SCHEMA.DESTINATION_NAME.value}.fact_game_results ORDER BY fact_game_results.match_id DESC LIMIT 1"""
        etl_df = return_data_as_df(
            file_executor= query,
            input_type= InputTypes.SQL,
            db_session= db_session
        )
        if len(etl_df) == 0:
            # choose oldest day possible.
            return_index=SEASONS.S18_19.value[0]
        else:
            return_index = etl_df['etl_last_run_index'].iloc[0]
            does_etl_index_exists=True
        return return_index,does_etl_index_exists
    except Exception as e:
        suffix = str(e)
        error_prefix = ErrorHandling.HOOK_DICT_RETURN_ERROR
        show_error_message(error_prefix.value, suffix)

def insert_or_update_etl_checkpoint(db_session, etl_index,does_etl_index_exists):
# update watermark
    
    if does_etl_index_exists:
        update_stmnt = f"UPDATE {DESTINATION_SCHEMA.DESTINATION_NAME.value}.etl_checkpoint SET etl_last_run_index = '{etl_index}'"
        execute_query(db_session, update_stmnt)
    else:
        insert_stmtnt=f"INSERT INTO {DESTINATION_SCHEMA.DESTINATION_NAME.value}.etl_checkpoint (etl_last_run_index) VALUES ({etl_index})"
        execute_query(db_session,insert_stmtnt)

def execute_hook():

    #Create a connection and start the fun
    db_session = create_connection()
    #Checkpoint created if doesn't exist
    create_etl_checkpoint(db_session)
    #Fetches last_id
    last_etl_id,does_etl_index_exists=return_etl_last_updated_index(db_session)
    #returns the last_player_game_index
    etl_index,return_df = return_last_match_df_from_web(last_etl_id)
    #retruns df with all the matches that aren't in the db
    return_match_df_from_web(last_etl_id, etl_index)
    insert_statement=return_insert_into_sql_statement_from_df_stg(return_df,WEBSCRAPINGSTAGINGTABLE.STGTABLENAME.value,DESTINATION_SCHEMA.DESTINATION_NAME.value)
    for insert in insert_statement:
        execute_query(db_session=db_session, query= insert)
    insert_or_update_etl_checkpoint(db_session,etl_index,does_etl_index_exists)

    #CSVS full refresh
    first_time_csv(db_session)

    #Standings full refresh
    insert_standings_into_stg(db_session)

    
    
    close_connection(db_session)