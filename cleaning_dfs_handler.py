from lookups import ErrorHandling
from logging_handler import show_error_message
from pandas_handler import process_net_transfer_record
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