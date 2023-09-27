from enum import Enum

class ErrorHandling(Enum):
    DB_CONNECT_ERROR = "DB Connect Error"
    DB_RETURN_QUERY_ERROR = "DB Return Query Error"
    API_ERROR = "Error calling API"
    RETURN_DATA_CSV_ERROR = "Error returning CSV"
    RETURN_DATA_EXCEL_ERROR = "Error returning Excel"
    RETURN_DATA_SQL_ERROR = "Error returning SQL"
    RETURN_DATA_UNDEFINED_ERROR = "Cannot find File type"
    EXECUTE_QUERY_ERROR = "Error executing the query"
    NO_ERROR = "No Errors"
    PREHOOK_SQL_ERROR = "Prehook: SQL Error"
    PREHOOK_CLOSE_CONNECTION_ERROR = "Error closing connection"
    HOOK_DICT_RETURN_ERROR = "Error returning lookup items as dict"
    DB_RETURN_INSERT_INTO_SQL_STMT_ERROR = "Return insert into sql dataframe error:"
    CSV_ERROR = "Error importing csv files from path"
    PANDAS_NULLS_ERROR = "Error dropping nulls from df"
    PANDAS_FILL_NULLS_ERROR="Error replacing nulls from df"
    RETURN_NET_TRASNFER_ERROR = "Error handling net transfer fee"
    CLUBS_ERROR = "Error cleaning clubs csv"
    PLAYERVALUATIONS_ERROR = "Error cleaning player valuations csv"

class InputTypes(Enum):
    SQL = "SQL"
    CSV = "CSV"
    EXCEL = "Excel"
    
class PreHookSteps(Enum):
    EXECUTE_SQL_QUERY = "execute_sql_folder"
    CREATE_SQL_STAGING = "create_sql_staging_tables"

class SourceName(Enum):
    DVD_RENTAL = "public"
    COLLEGE = "college"

class SQLTablesToReplicate(Enum):
    RENTAL = "public.rental"
    FILM = "public.film"
    ACTOR = "public.actor"
    STUDENTS = "college.student"

class IncrementalField(Enum):
    RENTAL = "rental_last_update"
    FILM = "film_last_update"
    ACTOR = "actor_last_update"

class ETLStep(Enum):
    PRE_HOOK = 0
    HOOK = 1

class DESTINATION_SCHEMA(Enum):
    DESTINATION_NAME = "premier_league"

class SEASONS(Enum):
    S22_23 = [74911,75290]
    S21_22 = [66342,66721]
    S20_21 = [58896,59275]
    S19_20 = [46605,46984]
    S18_19 = [38308,38688]

class URLS(Enum):
    Players = "https://drive.google.com/uc?id=1I3iBSRKtiIZxHG2yAr9JuYqBNbeGIOlI&export=download"
    Player_Valuations = "https://drive.google.com/uc?id=1Q1Dw7th4SxyR4OLQdo6M2tt6NRhYE7DE&export=download"
    Games = "https://drive.google.com/uc?id=1wEj6Tli0RKy7WsH6PydeWTdZTYx6iNsw&export=download"
    Games_Events = "https://drive.google.com/uc?id=1J-5WbdIHZy_hRQMOjlc5N55iUTE5NxMu&export=download"
    Competitions = "https://drive.google.com/uc?id=1FdewVTkWwUxjyTGbKFRjNMigSiJxw3Nq&export=download"
    Clubs = "https://drive.google.com/uc?id=1SD96aMVyrScGeUTSsCyd58mT9fjS5eFW&export=download"
    Appearances = "https://drive.google.com/uc?id=1nmK10IgDtTEIc1oC8zIt0w8aQDNleIKh&export=download"

class MAIN_SOURCE_CSV(Enum):
    url = 'https://www.kaggle.com/datasets/davidcariboo/player-scores'

class CSV_FOLDER_PATH(Enum):
    NAME = "tables"

class WEBSCRAPINGSTAGINGTABLE(Enum):
    STGTABLENAME = "web_stats"

class match_id(Enum):
    first_run_id_1=66342
    first_run_id_2=66343

class READURLS(Enum):
    # Players = "https://drive.google.com/file/d/1I3iBSRKtiIZxHG2yAr9JuYqBNbeGIOlI/view?usp=drive_link"
    # Player_Valuations = "https://drive.google.com/file/d/1Q1Dw7th4SxyR4OLQdo6M2tt6NRhYE7DE/view?usp=drive_link"
    # Games = "https://drive.google.com/file/d/1wEj6Tli0RKy7WsH6PydeWTdZTYx6iNsw/view?usp=drive_link"
    # Games_Events = "https://drive.google.com/file/d/1J-5WbdIHZy_hRQMOjlc5N55iUTE5NxMu/view?usp=drive_link"
    # Competitions = "https://drive.google.com/file/d/1FdewVTkWwUxjyTGbKFRjNMigSiJxw3Nq/view?usp=drive_link"
    Clubs = "https://drive.google.com/file/d/1SD96aMVyrScGeUTSsCyd58mT9fjS5eFW/view?usp=drive_link"
    # Appearances = "https://drive.google.com/file/d/1nmK10IgDtTEIc1oC8zIt0w8aQDNleIKh/view?usp=drive_link"