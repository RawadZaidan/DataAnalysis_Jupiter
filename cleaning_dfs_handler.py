from lookups import ErrorHandling
from logging_handler import show_error_message
from pandas_handler import process_net_transfer_record, drop_nulls, fill_nulls
import pandas as pd

#Function to clean clubs df
def clean_clubs_function(df):
    try:    
        filtered_df = df.loc[(df['domestic_competition_id'] == 'GB1') & (df['last_season'] >= 2018)].sort_values(by='net_transfer_record',ascending=True)
        columns_to_drop = ['total_market_value', 'coach_name', 'url']  # Replace with the actual column names you want to drop
        filtered_df.drop(columns=columns_to_drop, inplace=True)
        filtered_df['net_transfer_record'] = filtered_df['net_transfer_record'].apply(process_net_transfer_record)
        filtered_df.reset_index(inplace=True, drop=True)
        return filtered_df
    
    except Exception as e:
        error_string_prefix = ErrorHandling.CLUBS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)

#Function to clean player valuations df
def clean_player_valuations_function(df):
    try:
        columns_to_show = ['player_id','last_season','date','market_value_in_eur','current_club_id','player_club_domestic_competition_id']
        df = df[columns_to_show]
        df['date'] = pd.to_datetime(df['date'])
        df = df.loc[(df['player_club_domestic_competition_id'] == 'GB1') & 
                    (df['date'] >= pd.to_datetime('2018-08-10')) & 
                    (df['last_season'] >= 2018) &
                    ((df['last_season'] == df['date'].dt.year) | (df['last_season'] == (df['date'].dt.year - 1)))]
        df = df.sort_values(by='date', ascending=True)
        df.rename(columns={'player_club_domestic_competition_id': 'competition_id'}, inplace=True)
        df.reset_index(inplace=True, drop=True)
        return df
    except Exception as e:
        error_string_prefix = ErrorHandling.PLAYERVALUATIONS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)

def clean_players_function(df):
    try:
        columns_to_keep = ['player_id','name','last_season','current_club_id','country_of_citizenship','position',
                   'foot','height_in_cm','highest_market_value_in_eur','current_club_name','current_club_domestic_competition_id']
        df = df[columns_to_keep]
        df = df.loc[(df['last_season'] >= 2018) & (df['current_club_domestic_competition_id'] == 'GB1')].sort_values(by='highest_market_value_in_eur', ascending=False)
        df = drop_nulls(df, all=True)
        df = drop_nulls(df,False,['foot','height_in_cm'])
        df = fill_nulls(df,False,'highest_market_value_in_eur')
        df.reset_index(inplace=True, drop=True)
        return df
    except Exception as e:
        error_string_prefix = ErrorHandling.PLAYERVALUATIONS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)

def df_web_cleaning(web_df):
    drop_subset=['home_score','away_score']
    fill_subset=['home_shots_on_target','away_shots_on_target','away_shots','home_touches','away_touches','home_passes','away_passes','home_tackles','away_tackles','home_clearances',
                 'away_clearances','home_corners','away_corners','home_offsides','away_offsides','home_yellow_cards','away_yellow_cards',
                 'home_red_cards','away_red_cards','home_fouls_conceded','away_fouls_conceded']
    return_df=drop_nulls(web_df,column=drop_subset)
    return_df=fill_nulls(return_df,column=fill_subset)
    return_df['date']=pd.to_datetime(return_df['date'])
    return_df.columns=return_df.columns.str.replace("_%","")
    if return_df.columns[0]=='Unnamed: 0': 
        return_df.pop(return_df.columns[0])
    return return_df

def clean_games_function_georges(df):
    try:    
        filtered_df = df.loc[(df['competition_id'] == 'GB1') & (df['season'] >= 2018)].copy()
        columns_to_drop = ['url']  # Replace with the actual column names you want to drop
        filtered_df.drop(columns=columns_to_drop, inplace=True)
        filtered_df['aggregate'] = filtered_df[['home_club_goals','away_club_goals']].apply(lambda row: '-'.join(row.values.astype(str)), axis=1)
        filtered_df['date'] = pd.to_datetime(filtered_df['date'])
        filtered_df.reset_index(inplace=True, drop=True)
        return filtered_df
    
    except Exception as e:
        error_string_prefix = ErrorHandling.CLUBS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)

def clean_games_events_function_georges(df,df_games):
    try: 
        df_games=clean_games_function_georges(df_games)  
        filtered_df =pd.merge(df,df_games[['game_id','competition_id']],on='game_id',how='inner')
        filtered_df=filtered_df.loc[(filtered_df['competition_id'] == 'GB1')].copy()
        columns_to_drop = ['competition_id']  # Replace with the actual column names you want to drop
        filtered_df.drop(columns=columns_to_drop, inplace=True)
        filtered_df.reset_index(inplace=True, drop=True)
        return filtered_df
    
    except Exception as e:
        error_string_prefix = ErrorHandling.CLUBS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)