# main.py

from langchain.embeddings import HuggingFaceEmbeddings
from db_loader import db_loader
from qa_chain import qa_chain

# 벡터 DB 정보 설정
COLLECTION_NAME = "vectorDB_1.0"  # 생성된 벡터 DB의 이름
DB_PATH = "DB/vectorDB_1.0"  # 벡터 DB의 저장 경로

# 기본 임베딩 설정
embedding_function = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

# 벡터 DB 로드
vector_store = db_loader(
    embedding_function=embedding_function,
    collection_name=COLLECTION_NAME,
    path=DB_PATH
)

# vector_store가 제대로 생성되었는지 확인
if vector_store is None:
    raise ValueError("벡터 DB 로드 실패: vector_store가 None입니다.")
else:
    print("벡터 DB가 성공적으로 로드되었습니다.")

# 사용자의 질문에 대해 답변과 URL 제공
def get_answer_with_url(query, query_history=''):
    model_name = 'gpt-3.5-turbo'  # 사용할 LLM 모델
    answer = qa_chain(model_name, query_history, query, vector_store)
    
    # 유사도 검색 수행 및 URL 정보 포함
    results = vector_store.similarity_search(query, k=1)
    if results:
        url = results[0].metadata.get('url', 'URL을 찾을 수 없습니다')
        answer += f"\n\n관련 URL: {url}"
    
    return answer

# 메인 실행부
if __name__ == '__main__':
    print("질문을 입력하세요 (종료하려면 'exit' 입력):")
    query_history = ""

    while True:
        query = input("User: ")
        if query.lower() == "exit":
            break

        answer = get_answer_with_url(query, query_history)
        print(f"AI: {answer}")

        query_history += f"\nUser: {query}\nAI: {answer}\n"
