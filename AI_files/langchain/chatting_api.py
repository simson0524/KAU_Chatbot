from fastapi import FastAPI, Request
from pydantic import BaseModel
from langchain.embeddings import OpenAIEmbeddings
from custom_embeddings import *
from var_config import (EMBEDDING_FUNCTION,
                        COLLECTION_NAME,
                        LOCAL_DB_PATH,
                        MODEL_NAME)
from dotenv import load_dotenv
from db_loader import db_loader
from qa_chain import qa_chain
import os, json

"""
앱 서버에서 챗봇 채팅 api 요청이 들어올 때 처리하는 py파일입니다.
"""
load_dotenv()

# 가용 모델명
chat_gpt_model_name_list = ('gpt-4o', 'chatgpt-4o-latest', 'gpt-4o-mini',
                             'gpt-4-turbo', 'gpt-3.5-turbo')
gemini_model_name_list = ('gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro')

app = FastAPI()

vector_store = db_loader(
    embedding_function=EMBEDDING_FUNCTION,
    collection_name=COLLECTION_NAME,
    path=LOCAL_DB_PATH
    )

# vector_store가 제대로 생성되었는지 확인
if vector_store is None:
    raise ValueError("벡터 DB 로드 실패: vector_store가 None입니다.")
else:
    print("벡터 DB가 성공적으로 로드되었습니다.")
    all_data = vector_store.get(include=['documents'])
    print('db길이', len( all_data['documents'] ))

# 사용자의 질문에 대해 답변과 URL 제공
def get_answer_with_url(query, character):
    answer, tags = qa_chain(query, vector_store, character)
    answer = answer['answer']
    
    # 유사도 검색 수행 및 URL 정보 포함
    results = vector_store.similarity_search(query, k=3)
    if results:
        for result in results:
            print(type(answer), answer)
            url = result.metadata.get('url', 'URL을 찾을 수 없습니다')
            answer += f"\n\n관련 URL: {url}"

    return answer, tags



# server에서 RAG 인스턴스로 쿼리를 받는 Request객체 정의
class QueryRequest(BaseModel):
    query: str
    character: str

@app.post("/chat")
async def chat(query_request: QueryRequest):
    query = query_request.query
    character = query_request.character
    
    answer, tags = get_answer_with_url(query, character)

    freq_tag = set()
    filename = "freq_tag.json"
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as file:
            freq_tag = set(json.load(file))

    final_tags = []

    for tag in tags:
        if tag in freq_tag:
            final_tags.append(tag)

    return {'answer': answer, 'tag': final_tags}