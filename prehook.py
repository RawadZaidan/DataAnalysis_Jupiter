import os
from database_handler import execute_query, create_connection, close_connection,return_data_as_df, return_create_statement_from_df,return_create_statement_from_df_stg
from lookups import ErrorHandling, PreHookSteps, SQLTablesToReplicate, InputTypes, SourceName, DESTINATION_SCHEMA,match_id,WEBSCRAPINGSTAGINGTABLE
from logging_handler import show_error_message
from pandas_handler import get_csv_file_names_into_dict, return_paths_dict
from misc_handler import download_files,return_match_df_from_web
from database_handler import create_connection
import pandas as pd

def first_time_run_download():
    db_session = create_connection()
    download_files()
    create_stg_tables_from_csv(db_session)

def first_time_web_scraping():
    db_session=create_connection()
    df_web_stg=return_match_df_from_web(match_id.first_run_id_1.value,match_id.first_run_id_2.value)
    df_web_stg['date']=pd.to_datetime(df_web_stg['date'])
    df_web_stg.columns=df_web_stg.columns.str.replace("_%","")
    create_statement=return_create_statement_from_df_stg(df_web_stg,DESTINATION_SCHEMA.DESTINATION_NAME.value,WEBSCRAPINGSTAGINGTABLE.STGTABLENAME.value)
    execute_query(db_session,create_statement)




#DONE: Executes the sql folder commands: Creates the schema if it doesn't exist
def execute_sql_folder(db_session, sql_command_directory_path):
    try:
        sql_files = [sqlfile for sqlfile in os.listdir(sql_command_directory_path) if sqlfile.endswith('.sql')]
        sorted_sql_files =  sorted(sql_files)
        for sql_file in sorted_sql_files:
            with open(os.path.join(sql_command_directory_path,sql_file), 'r') as file:
                sql_query = file.read()
                return_val = execute_query(db_session= db_session, query= sql_query)
                if not return_val == ErrorHandling.NO_ERROR:
                    raise Exception(f"{PreHookSteps.EXECUTE_SQL_QUERY.value} = SQL File Error on SQL FILE = " +  str(sql_file))
    except Exception as error:
        suffix = str(error)
        error_prefix = ErrorHandling.PREHOOK_SQL_ERROR
        show_error_message(error_prefix.value, suffix)

#DONE: Returnes list of tables in the schema/source that i want to include in my Hook
def return_tables_by_schema(schema_name):
    schema_tables = list()
    tables = [table.value for table in SQLTablesToReplicate]
    for table in tables:
        if table.split('.')[0] == schema_name:
            schema_tables.append(table.split('.')[1])
    return schema_tables

#DONE: Create the index for the staging tables if it doesn't exist
def create_sql_staging_table_index(db_session,source_name, table_name, index_val):
    query = f"CREATE INDEX IF NOT EXISTS idx_{table_name}_{index_val} ON {source_name}.{table_name} ({index_val});"
    execute_query(db_session,query)

#DONE: Gets names of SQL tables to replicate from SQLTABLESTOREPLICATE and Creates the staging Tables
def create_sql_staging_tables(db_session, source_name):
    try:
        source_name = source_name.value
        tables = return_tables_by_schema(source_name)
        for table in tables:
            staging_query = f"""
                    SELECT * FROM {source_name}.{table} LIMIT 1
            """
            staging_df = return_data_as_df(db_session= db_session, input_type= InputTypes.SQL, file_executor= staging_query)
            columns = list(staging_df.columns)
            dst_table = f"stg_{source_name}_{table}"
            create_stmt = return_create_statement_from_df(staging_df, DESTINATION_SCHEMA.DESTINATION_NAME.value, dst_table)
            execute_query(db_session=db_session, query= create_stmt)
            create_sql_staging_table_index(db_session, DESTINATION_SCHEMA.DESTINATION_NAME.value, dst_table, columns[0])
    except Exception as error:
        return staging_query

#DONE: Executes prehook
def execute_prehook(sql_command_directory_path='./SQL_Commands'):
    step_name = ""
    db_session = None
    try:
        step_name = "DB CONNECTION ERROR"
        db_session = create_connection()
        step_name = "SQL FOLDER ERROR"
        execute_sql_folder(db_session, sql_command_directory_path) 
        step_name = "SQL TABLES CREATION ERROR"
        create_sql_staging_tables(db_session, SourceName.DVD_RENTAL)
        step_name = "CLOSING CONNECTION ERROR"
        close_connection(db_session)
    except Exception as error:
        suffix = str(error)
        error_prefix = ErrorHandling.PREHOOK_SQL_ERROR
        show_error_message(error_prefix.value, suffix)
        raise Exception(f"Important Step Failed step = {step_name}")
    finally:
        if db_session:
            close_connection(db_session)

def create_stg_tables_from_csv(db_session):
    dict_csvs = get_csv_file_names_into_dict()
    dict_csvs_paths = return_paths_dict(dict_csvs)
    for table_name,path in dict_csvs_paths.items():
        df = return_data_as_df(file_executor=path , input_type=InputTypes.CSV)
        query = return_create_statement_from_df_stg(df, DESTINATION_SCHEMA.DESTINATION_NAME.value, table_name)
        execute_query(db_session=db_session, query=query)
        print("Done")

def new_execute_prehook(sql_command_directory_path='./SQL_Commands'):
    try:
        #Create connection to PG
        db_session = create_connection()

        #Execute Sql file: New schema 
        execute_sql_folder(db_session, sql_command_directory_path)

        #Create staging tables from CSV
        create_stg_tables_from_csv(db_session)
        
        #Execute Webscraping function (Georges)


        #Close the connection
        close_connection(db_session)
        
    except Exception as error:
        suffix = str(error)
        error_prefix = ErrorHandling.PREHOOK_SQL_ERROR
        show_error_message(error_prefix.value, suffix)