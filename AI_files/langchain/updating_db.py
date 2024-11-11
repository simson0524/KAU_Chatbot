from langchain_community.embeddings import OpenAIEmbeddings
from custom_embeddings import *
from document_loader import document_loader
from db_creator import db_creator
from var_config import (EMBEDDING_FUNCTION, 
                        CSV_FILE_PATH, 
                        COLLECTION_NAME,
                        LOCAL_DB_PATH)
from dotenv import load_dotenv
import os

load_dotenv()

# csv파일들 경로 넣어두기
csv_file_path_list = [CSV_FILE_PATH]

# 처리된 데이터들 들어갈 리스트
documents_list = []

# 데이터를 LangChain에 맞게 세팅
for file_path in csv_file_path_list:
    documents = document_loader(csv_file_path=file_path)
    documents_list += documents

# 처리된 데이터로 embedding function이용하여 임베딩해서 벡터DB생성
db_creator(
    embedding_function=EMBEDDING_FUNCTION,
    documents=documents_list,
    collection_name=COLLECTION_NAME,
    path=LOCAL_DB_PATH,
    )