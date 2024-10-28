from langchain_openai import OpenAIEmbeddings
import os
from custom_embeddings import *
from document_loader import document_loader
from db_creator import db_creator

# TODO : 사용할 것들 설정하기
# 사용할 임베딩 함수 설정


# OpenAI API 키 설정
os.environ["OPENAI_API_KEY"] = "s"
EMBEDDING_FUNCTION = OpenAIEmbeddings(model="text-embedding-ada-002")

# 경로 및 설정 정보
CSV_FILE_PATH = "crawling/csv_files/crawl_complete_data_test.csv"  # CSV 파일 경로
COLLECTION_NAME = "vectorDB_1.3"  # 벡터 DB 컬렉션 이름
DB_PATH = f"DB/{COLLECTION_NAME}"  # 로컬에 벡터 DB를 저장할 경로
# 외부에 저장되어 있는 DB의 경로

# csv파일들 경로 넣어두기
csv_file_path_list = [CSV_FILE_PATH]

# 처리된 데이터들 들어갈 리스트
documents_list = []

# 데이터를 LangChain에 맞게 세팅
for file_path in csv_file_path_list:
    documents = document_loader(csv_file_path=file_path)
    documents_list += documents

# 처리된 데이터로 embedding function이용하여 임베딩해서 벡터DB생성
db_creator(embedding_function=EMBEDDING_FUNCTION,
           documents=documents_list,
           collection_name=COLLECTION_NAME,
           path=DB_PATH
           )