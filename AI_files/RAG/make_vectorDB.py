from document_loader import document_loader
from db_creator import db_creator
from langchain.embeddings import HuggingFaceEmbeddings

# 경로 및 설정 정보
CSV_FILE_PATH = "crawling/csv_files/crawl_complete_data.csv"  # CSV 파일 경로
COLLECTION_NAME = "vectorDB_1.0"  # 벡터 DB 컬렉션 이름
DB_PATH = f"DB/{COLLECTION_NAME}"  # 로컬에 벡터 DB를 저장할 경로

# CSV 파일을 Document 형식으로 로드
documents = document_loader(CSV_FILE_PATH)

# ChromaDB에서 사용할 기본 임베딩 설정 (sentence-transformers의 모델 사용)
embedding_function = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

# 벡터 DB 생성
db_creator(
    embedding_function=embedding_function,  # 기본 임베딩 함수 사용
    documents=documents,
    collection_name=COLLECTION_NAME,
    path=DB_PATH
)

print(f"벡터DB가 성공적으로 '{DB_PATH}' 경로에 생성되었습니다.")
