from lookups import ErrorHandling
from logging_handler import show_error_message
from pandas_handler import process_net_transfer_record

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