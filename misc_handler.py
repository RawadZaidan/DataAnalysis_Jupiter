import os
import requests
from lookups import URLS
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from time import sleep
from datetime import datetime
import pandas as pd
from pandas_handler import drop_nulls,fill_nulls
from lookups import CSV_FOLDER_PATH,InputTypes,DESTINATION_SCHEMA,WEBSCRAPINGSTAGINGTABLE
from database_handler import return_data_as_df,return_insert_into_sql_statement_from_df_stg,execute_query
from cleaning_dfs_handler import df_web_cleaning

def read_csv_files_from_drive(url):
    file_id = url.split("/")[-2]
    reading_link = f"https://drive.google.com/uc?id={file_id}"
    df = pd.read_csv(reading_link)
    return df

def download_files(output_folder = CSV_FOLDER_PATH.NAME.value):
    os.makedirs(output_folder, exist_ok=True) # if folder doesn't exists, it creates one
    for url_enum in URLS:
        url = url_enum.value
        table_name = url_enum.name
        try:
            r = requests.get(url, allow_redirects=True)
            r.raise_for_status()
            file_name = f"{table_name}.csv"
            file_path = os.path.join(output_folder, file_name)
            with open(file_path, 'wb') as file:
                file.write(r.content)
            print(f"Downloaded {file_name} to {output_folder}")
            print(f'File path is {output_folder}')
        except Exception as e:
            print(f"Failed to download file {table_name}: {str(e)}")

def find_csv_files(directory):
   csv_files = []
   for root, _, files in os.walk(directory):
      for file in files:
         if file.endswith('.csv'):
            csv_files.append(os.path.join(root, file))
   return csv_files

def return_match_df_from_web(first_id,last_id):
    match_details=[]
    driver = webdriver.Chrome()
    options=Options()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)
    for match_id in range(first_id,last_id):
        url = f'https://www.premierleague.com/match/{match_id}'
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
            home_score=None
            away_score=None
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
        match_stats= [match_id,date, home_team, away_team, home_score, away_score, home_stats['possession_%'], away_stats['possession_%'],
                    home_stats['shots_on_target'], away_stats['shots_on_target'], home_stats['shots'], away_stats['shots'],
                    home_stats['touches'], away_stats['touches'], home_stats['passes'], away_stats['passes'],
                    home_stats['tackles'], away_stats['tackles'], home_stats['clearances'], away_stats['clearances'],
                    home_stats['corners'], away_stats['corners'], home_stats['offsides'], away_stats['offsides'],
                    home_stats['yellow_cards'], away_stats['yellow_cards'], home_stats['red_cards'], away_stats['red_cards'],
                    home_stats['fouls_conceded'], away_stats['fouls_conceded']]
        match_details.append(match_stats)
    match_df = pd.DataFrame(match_details,columns=columns)
    driver.quit()
    return match_df


def insert_web_into_sql(db_session,source_folder):
    csv_files=find_csv_files(source_folder)
    for file in csv_files:
        df=return_data_as_df(file,InputTypes.CSV)
        df=df_web_cleaning(df)
        insert_statement=return_insert_into_sql_statement_from_df_stg(df,WEBSCRAPINGSTAGINGTABLE.STGTABLENAME.value,DESTINATION_SCHEMA.DESTINATION_NAME.value)
        for insert in insert_statement:
            execute_query(db_session=db_session, query= insert)


def return_standings_df_from_web():
    driver = webdriver.Chrome()
    options=Options()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)
    url='https://www.premierleague.com/tables'
    driver.get(url)
    sleep(3)
    table_df=pd.read_html(driver.page_source)
    table_df=table_df[0].iloc[::2]
    standings=table_df.copy()
    standings['Position']=table_df['Position'].astype(str).str[:2]
    standings.drop(columns=['Form','Next','More'],inplace=True)
    standings.reset_index()
    return standings
