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
챗봇 채팅 테스트하는 py파일입니다.
"""
load_dotenv()

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
    results = vector_store.similarity_search(query, 
                                             k=3)
    if results:
        # # print(type(answer), answer)
        # url = results[0].metadata.get('url', 'URL을 찾을 수 없습니다')
        # answer += f"\n\n관련 URL: {url}"

        for result in results:
            print(result.metadata)
            url = result.metadata.get('url', 'URL을 찾을 수 없습니다.')
            answer += f"\n\n관련 URL: {url}"

    return answer, tags



while True:
    character = input("maha, mile, feet 중 캐릭터를 입력하십시오 ->")
    query = input("질문할 내용을 입력하십시오 ->")

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

    print('답변 ->', answer, '\n\n\n')
    print('태그정보 ->', final_tags)