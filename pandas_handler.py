import os
from lookups import ErrorHandling, CSV_FOLDER_PATH
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
        return return_df

def get_csv_file_names_into_list(folder_path = CSV_FOLDER_PATH.NAME.value):
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
    
def get_blanks(df):
    blank_df = None
    try:
        blank_df = df.isnull().any(axis=1)
    except Exception as e:
        error_string_prefix = ErrorHandling.PANDAS_BLANKS_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return blank_df

def get_shape(df):
    Shape = None
    try:
        blank_df = df.shape
    except Exception as e:
        error_string_prefix = ErrorHandling.PANDAS_SHAPE_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return Shape
    
def get_length(df):
    Length = None
    try:
        blank_df = len(df)
    except Exception as e:
        error_string_prefix = ErrorHandling.PANDAS_LEN_ERROR.value
        error_string_suffix = str(e)
        show_error_message(error_string_prefix, error_string_suffix)
    finally:
        return Length
    
def remove_spaces_from_columns_df(df):
    for column in df.columns:
        new_column_name = column.replace(' ', '_')
        df.rename(columns={column: new_column_name}, inplace=True)
    return df

def remove_spaces_from_string(name):
    name = name.replace(' ', '_')
    return name

def return_paths(list_of_paths, subfolder_name): 
    return_path_list = []
    current_directory = os.getcwd()
    subfolder_path = os.path.join(current_directory, subfolder_name)
    for file in list_of_paths:
        cssss= file
        item_relative_path = os.path.join(subfolder_path, cssss)
        name_of_table = remove_spaces_from_string(file[:-4])
        return_path_list.append([name_of_table,item_relative_path])
    return return_path_list

def return_paths_as_dict(list_of_paths, subfolder_name):
    return_path_dict = {}
    current_directory = os.getcwd()
    subfolder_path = os.path.join(current_directory, subfolder_name)
    for file in list_of_paths:
        cssss = file
        item_relative_path = os.path.join(subfolder_path, cssss)
        name_of_table = remove_spaces_from_string(file[:-4])
        return_path_dict[name_of_table] = item_relative_path
    return return_path_dict

def return_files_and_paths_as_dict(folder_name):
    csvs_dict = {key:value for item in folder_name}