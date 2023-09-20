import os
from lookups import ErrorHandling
from logging_handler import show_error_message
import pandas as pd

def remove_duplicates(df, column=None):
    try:
        df_no_duplicates = None
        if column is None:
            df = df.drop_duplicates()
        else:
            df_no_duplicates = df.drop_duplicates(subset=[column])
        return df_no_duplicates
    except Exception as e:
        error_string_prefix = ErrorHandling.DB_RETURN_QUERY_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return df_no_duplicates

#This function automatically drops any row with a None value
def drop_nulls(df, all=False, column=None):
    try:
        return_df = df
        if all:
            return_df = df.dropna(how='all')
        elif column is not None:
            return_df = df.dropna(subset=[column])
        elif column is not None and all:
            print('Please pick only 1 type. Leave empty for any, all for rows ')
        else:
            return_df = df.dropna()
        return return_df
    except Exception as e:
        error_string_prefix = ErrorHandling.PANDAS_NULLS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return df

def get_csv_file_names_into_list(folder_path):
    try:
        csv_files_names = []
        for filename in os.listdir(folder_path):
            if filename[-4:] == ".csv":
                csv_files_names.append(filename)
    except Exception as e:
        error_string_prefix = ErrorHandling.CSV_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return csv_files_names