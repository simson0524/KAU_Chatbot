from langchain.embeddings import OpenAIEmbeddings

from custom_embeddings import *
from document_loader import document_loader
from db_creator import db_creator

# TODO : 사용할 것들 설정하기
# 사용할 임베딩 함수 설정
EMBEDDING_FUNCTION = OpenAIEmbeddings()

# 불러올 DB의 이름
COLLECTION_NAME = ''

# 로컬에 저장되어 있는 DB의 경로
DB_PATH = None

# 외부에 저장되어 있는 DB의 경로
DB_URL = None

# csv파일들 경로 넣어두기
csv_file_path_list = []

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
           path=DB_PATH,
           db_server_url=DB_URL)