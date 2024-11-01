from document_loader import document_loader
from db_creator import db_creator
from var_config import (EMBEDDING_FUNCTION, 
                        CSV_FILE_PATH, 
                        COLLECTION_NAME,
                        LOCAL_DB_PATH)

documents = document_loader(csv_file_path=CSV_FILE_PATH)

db_creator(
    embedding_function=EMBEDDING_FUNCTION,
    documents=documents,
    collection_name=COLLECTION_NAME,
    persist_path=LOCAL_DB_PATH
)