from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from time import sleep
from datetime import datetime
import pandas as pd

#Finalized function
# def return_match_df_from_web(first_id,last_id):
#     match_details=[]
#     driver = webdriver.Chrome()
#     options=Options()
#     options.add_argument('--headless')
#     driver = webdriver.Chrome(options=options)
#     for match_id in range(first_id,last_id):
#         url = f'https://www.premierleague.com/match/{match_id}'
#         driver.get(url)
#         date = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[1]/div[1]'))).text
#         date = datetime.strptime(date, '%a %d %b %Y').strftime('%m/%d/%Y')
#         home_team= WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[1]/div[1]/a[2]/span[1]'))).text
#         away_team= WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[3]/div[1]/a[2]/span[1]'))).text
#         score=WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[2]/div[1]'))).text
#         home_score = score.split(' -')[0]
#         away_score = score.split('- ')[1]
#         stats= WebDriverWait(driver, 3).until(EC.element_to_be_clickable((By.XPATH,'//*[@id="mainContent"]/div/section[2]/div[2]/div/div[1]/div/div/ul/li[3]')))
#         driver.execute_script("arguments[0].click();",stats)
#         sleep(3)
#         match_stats_df=pd.read_html(driver.page_source)
#         #driver.quit()
#         match_stats_df=match_stats_df[-1]
#         home_stats = {}
#         away_stats = {}
#         home_series = match_stats_df[home_team]
#         away_series = match_stats_df[away_team]
#         stats_series = match_stats_df['Unnamed: 1']
#         for row in zip(home_series, stats_series, away_series):
#             stat = row[1].replace(' ', '_').lower()
#             home_stats[stat] = row[0]
#             away_stats[stat] = row[2]
#         all_stats = ['possession_%', 'shots_on_target', 'shots', 'touches', 'passes','tackles', 'clearances', 'corners', 'offsides', 'yellow_cards','red_cards', 'fouls_conceded']
#         columns = ['date', 'home_team', 'away_team', 'home_score', 'away_score']
#         for stat in all_stats:
#             if stat not in home_stats.keys():
#                 home_stats[stat] = 0
#                 away_stats[stat] = 0
#             columns.append(f'home_{stat}')
#             columns.append(f'away_{stat}')
#         match_stats= [date, home_team, away_team, home_score, away_score, home_stats['possession_%'], away_stats['possession_%'],
#                     home_stats['shots_on_target'], away_stats['shots_on_target'], home_stats['shots'], away_stats['shots'],
#                     home_stats['touches'], away_stats['touches'], home_stats['passes'], away_stats['passes'],
#                     home_stats['tackles'], away_stats['tackles'], home_stats['clearances'], away_stats['clearances'],
#                     home_stats['corners'], away_stats['corners'], home_stats['offsides'], away_stats['offsides'],
#                     home_stats['yellow_cards'], away_stats['yellow_cards'], home_stats['red_cards'], away_stats['red_cards'],
#                     home_stats['fouls_conceded'], away_stats['fouls_conceded']]
#         match_details.append(match_stats)
#     match_df = pd.DataFrame(match_details,columns=columns)
#     driver.quit()
#     match_stats_df=match_stats_df[-1]
#     home_stats = {}
#     away_stats = {}
#     home_series = match_stats_df[home_team]
#     away_series = match_stats_df[away_team]
#     stats_series = match_stats_df['Unnamed: 1']
#     for row in zip(home_series, stats_series, away_series):
#         stat = row[1].replace(' ', '_').lower()
#         home_stats[stat] = row[0]
#         away_stats[stat] = row[2]
#     all_stats = ['possession_%', 'shots_on_target', 'shots', 'touches', 'passes','tackles', 'clearances', 'corners', 'offsides', 'yellow_cards','red_cards', 'fouls_conceded']
#     columns = ['date', 'home_team', 'away_team', 'home_score', 'away_score']
#     for stat in all_stats:
#         if stat not in home_stats.keys():
#             home_stats[stat] = 0
#             away_stats[stat] = 0
#         columns.append(f'home_{stat}')
#         columns.append(f'away_{stat}')
#     match_stats= [date, home_team, away_team, home_score, away_score, home_stats['possession_%'], away_stats['possession_%'],
#                  home_stats['shots_on_target'], away_stats['shots_on_target'], home_stats['shots'], away_stats['shots'],
#                  home_stats['touches'], away_stats['touches'], home_stats['passes'], away_stats['passes'],
#                  home_stats['tackles'], away_stats['tackles'], home_stats['clearances'], away_stats['clearances'],
#                  home_stats['corners'], away_stats['corners'], home_stats['offsides'], away_stats['offsides'],
#                  home_stats['yellow_cards'], away_stats['yellow_cards'], home_stats['red_cards'], away_stats['red_cards'],
#                  home_stats['fouls_conceded'], away_stats['fouls_conceded']]
#     match_details.append(match_stats)
#     match_df = pd.DataFrame(match_details,columns=columns)
#     return match_df

import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from datetime import datetime

def return_match_df_from_web(first_id,last_id):
    match_details=[]
    driver = webdriver.Chrome()
    options=Options()
    options.add_argument('--headless')
    driver = webdriver.Chrome(options=options)
    for match_id in range(first_id,last_id):
        url = f'https://www.premierleague.com/match/{match_id}'
        driver.get(url)
        date = WebDriverWait(driver, 6).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[1]/div[1]'))).text
        date = datetime.strptime(date, '%a %d %b %Y').strftime('%m/%d/%Y')
        home_team= WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[1]/div[1]/a[2]/span[1]'))).text
        away_team= WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[3]/div[1]/a[2]/span[1]'))).text
        score=WebDriverWait(driver, 2).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="mainContent"]/div/section[2]/div[2]/section/div/div[2]/div/div[2]/div[1]'))).text
        home_score = score.split(' -')[0]
        away_score = score.split('- ')[1]
        stats= WebDriverWait(driver, 3).until(EC.element_to_be_clickable((By.XPATH,'//*[@id="mainContent"]/div/section[2]/div[2]/div/div[1]/div/div/ul/li[3]')))
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
        columns = ['date', 'home_team', 'away_team', 'home_score', 'away_score']
        for stat in all_stats:
            if stat not in home_stats.keys():
                home_stats[stat] = 0
                away_stats[stat] = 0
            columns.append(f'home_{stat}')
            columns.append(f'away_{stat}')
        match_stats= [date, home_team, away_team, home_score, away_score, home_stats['possession_%'], away_stats['possession_%'],
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