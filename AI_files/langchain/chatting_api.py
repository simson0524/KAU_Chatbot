from fastapi import FastAPI, Request
from pydantic import BaseModel
from langchain.embeddings import OpenAIEmbeddings
from custom_embeddings import *
from var_config import (EMBEDDING_FUNCTION,
                        COLLECTION_NAME,
                        LOCAL_DB_PATH,
                        EXTERNAL_DB_URL,
                        MODEL_NAME)
from db_loader import db_loader
from qa_chain import qa_chain

"""
앱 서버에서 챗봇 채팅 api 요청이 들어올 때 처리하는 py파일입니다.
"""

# 가용 모델명
chat_gpt_model_name_list = ('gpt-4o', 'chatgpt-4o-latest', 'gpt-4o-mini',
                             'gpt-4-turbo', 'gpt-3.5-turbo')
gemini_model_name_list = ('gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro')

app = FastAPI()

vector_store = db_loader(
    embedding_function=EMBEDDING_FUNCTION,
    collection_name=COLLECTION_NAME,
    path=LOCAL_DB_PATH,
    db_server_url=EXTERNAL_DB_URL
    )

# server에서 RAG 인스턴스로 쿼리를 받는 Request객체 정의
class QueryRequest(BaseModel):
    query: str
    character: str

@app.post("/chat")
async def chat(query_request: QueryRequest):
    query = query_request.query
    character = query_request.character
    
    answer = qa_chain(character=character,
                      query=query,
                      vector_store=vector_store)
    
    # TODO : user query의 tag쏴줄거 지정하기
    tag = None

    return {'answer': answer, 'tag': tag}