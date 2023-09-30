from hookpart2 import execute_hook,create_etl_checkpoint, return_etl_last_updated_index
from database_handler import create_connection, execute_query
from prehook import return_data_as_df
from lookups import InputTypes, DESTINATION_SCHEMA


def post_hook_cleanup(db_session):
    query = f"""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = '{DESTINATION_SCHEMA.DESTINATION_NAME.value}'
            """
    df = return_data_as_df(file_executor=query, input_type= InputTypes.SQL, db_session = db_session)
    for row in df.iloc[:, 0].tolist():
        if row[:3] == 'stg':
            truncate_query = f"TRUNCATE TABLE {DESTINATION_SCHEMA.DESTINATION_NAME.value}.{row} RESTART IDENTITY CASCADE;"
            execute_query(db_session,truncate_query)

def execute_posthook(db_session):

    db_session = create_connection()

    post_hook_cleanup(db_session)