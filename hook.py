from database_handler import execute_query, create_connection, close_connection,return_data_as_df, return_insert_into_sql_statement_from_df
from lookups import InputTypes, IncrementalField,  DESTINATION_SCHEMA, ErrorHandling
from datetime import datetime
from logging_handler import show_error_message

#DONE, Tested: Create last ETL table in the new schema
def create_etl_checkpoint(db_session):
    schema_destination_table = DESTINATION_SCHEMA.DESTINATION_NAME.value
    query = f"""
        CREATE TABLE IF NOT EXISTS {schema_destination_table}.etl_checkpoint
        (
            etl_last_run_date TIMESTAMP
        )
        """
    execute_query(db_session, query)

#unfinished function
def insert_or_update_etl_checkpoint(db_session, etl_date = None):
    pass
    # update watermark
    # last_rental_date = str(df_rental['rental_date'].max())
    # if len(df_rental) > 0:
    #     update_stmnt = f"UPDATE public.etl_index SET etl_last_run_date = '{last_rental_date}'"
    #     database_handler.execute_query(db_session, update_stmnt)

#DONE, Tested: Returns Every table and its etl comparison column name as a DICT
def return_lookup_items_as_dict(lookup_item):
    try:
        enum_dict = {str(item.name).lower():item.value.replace(item.name.lower() + "_","") for item in lookup_item}
        return enum_dict
    except Exception as error:
        suffix = str(error)
        error_prefix = ErrorHandling.HOOK_DICT_RETURN_ERROR
        show_error_message(error_prefix.value, suffix)

#
def read_source_df_insert_into_dest(db_session, source_name, etl_date = None):
    try:
        #SourceName is schema name
        source_name = source_name.value
        #This will get you a list of tables inside this schema that are mentioned in SQLTablesToReplicate
        tables = return_tables_by_schema(source_name)
        #This will return each table and its ETL last update column name as dict key/value
        incremental_date_dict = return_lookup_items_as_dict(IncrementalField)
        for table in tables:
            staging_query = f"""
                    SELECT * FROM {source_name}.{table} WHERE {incremental_date_dict.get(table)} >= '{etl_date}'
            """ 
            staging_df = return_data_as_df(db_session= db_session, input_type= InputTypes.SQL, file_executor= staging_query)
            dst_table = f"stg_{source_name}_{table}"
            insert_stmt = return_insert_into_sql_statement_from_df(staging_df, DESTINATION_SCHEMA.DESTINATION_NAME.value, dst_table)
            for insert in insert_stmt:
                execute_query(db_session=db_session, query= insert)
    except Exception as error:
        suffix = str(error)
        error_prefix = ErrorHandling.HOOK_DICT_RETURN_ERROR
        show_error_message(error_prefix.value, suffix)
    
def return_etl_last_updated_date(db_session):
    try:
        query = f"SELECT etl_last_run_date FROM {DESTINATION_SCHEMA.DESTINATION_NAME.value}.etl_checkpoint ORDER BY etl_last_run_date DESC LIMIT 1"
        etl_df = return_data_as_df(
            file_executor= query,
            input_type= InputTypes.SQL,
            db_session= db_session
        )
        if len(etl_df) == 0:
            # choose oldest day possible.
            return_date = datetime.datetime(1992,6,19)
        else:
            return_date = etl_df['etl_last_run_date'].iloc[0]
        return return_date
    except Exception as e:
        suffix = str(e)
        error_prefix = ErrorHandling.HOOK_DICT_RETURN_ERROR
        show_error_message(error_prefix.value, suffix)
        
def execute_hook():
    db_session = create_connection()
    create_etl_checkpoint(db_session)
    etl_date = return_etl_last_updated_date(db_session)
    read_source_df_insert_into_dest(db_session,DESTINATION_SCHEMA.DESTINATION_NAME.value, etl_date)
    # start applying transformation 
    # build dimensions.
    # build facts.
    # build aggregates.
    
    close_connection(db_session)