import chromadb

def search_similar_documents(query_text, demo_version, n_results):
    db_path = f'database/vectorDB_{demo_version}'
    collection_name = f'vectorDB_{demo_version}'
    
    COLLECTION_NAME = collection_name
    
    client = chromadb.PersistentClient(path=db_path)
    collection = client.get_collection(COLLECTION_NAME)
    
    # 쿼리 텍스트를 입력으로 받아 임베딩하고 유사한 문서를 검색
    results = collection.query(
        query_texts=[query_text],
        n_results=n_results
    )

    return results
    
    # # 검색 결과 출력
    # print(f"쿼리: {query_text}")
    # print(f"상위 {n_results}개의 유사한 문서:")
    # for i, (doc, meta) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
    #     print(f"{i+1}. 제목: {meta['title']}, URL: {meta['url']}, 작성일: {meta['date']}, 첨부파일: {meta['attachments']}")
#     #     print(f"문서 내용: {doc[:200]}...")  # 문서 내용 앞부분만 출력

# # 사용 예시
# csv_file_name = 'dataset.csv'
# demo_version = '0.1'

# # 유사도 검색
# query_text = "9월 23일"  # 검색할 쿼리 텍스트
# search_similar_documents(query_text, demo_version, n_results=5)
