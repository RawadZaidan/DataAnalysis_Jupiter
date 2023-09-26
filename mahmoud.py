from pandas_handler import process_net_transfer_record, drop_nulls, fill_nulls
import pandas as pd

def clean_competitions_function(df):  
   df = df.loc[
    (df['competition_id'] == 'GB1') &
    (df['country_name'] == 'England')
]
   return df

def clean_appearances_function(df):
   df['date'] = pd.to_datetime(df['date'])
   df = df.loc[
   (df['date'].dt.year >= 2018) & 
   (df['competition_id'] == 'GB1')
   ]
   return df