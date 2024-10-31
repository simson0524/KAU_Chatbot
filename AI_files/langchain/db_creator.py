from langchain_chroma.vectorstores import Chroma
import time

"""
[RAG using LangChain - 2] DB 생성하기

생성한 Document들을 갖고 특정 임베딩함수를 이용해 DB를 생성하는 db_creator함수를 정의한 py파일입니다.
"""
def db_creator(embedding_function, documents, collection_name, path=None):
    """ 벡터 DB를 생성하고 Document들을 임베딩함수를 사용하여 벡터 DB에 정보를 저장하는 함수

    Args:
        embedding_function (Embeddings): 사용할 임베딩 함수명
        documents (list): document_loder함수를 사용하여 생성한 Document객체들의 리스트
        collection_name (str): collection name, 생성할 DB의 이름
        path (str, optional): 생성할 DB 인스턴스를 저장할 경로. Defaults to None.
    """
    half_documents_length = len( documents ) // 2
    print('db 저장될 데이터의 수:', len(documents))
    
    # DB 정의
    db = Chroma(
        collection_name=collection_name,
        embedding_function=embedding_function,
        persist_directory=path
    )

    print('db정의 완료')
    
    # 1차 데이터 업데이트
    documents_list_1 = documents[:half_documents_length]
    print('1')
    db.add_documents(documents=documents_list_1)
    print('1차 데이터 길이:', len(documents_list_1))
    
    # 분당 토큰 제한 해결책
    time.sleep(70)
    print('2')

    # 2차 데이터 업데이트
    documents_list_2 = documents[half_documents_length:]
    print('3')
    db.add_documents(documents=documents_list_2)
    print('2차 데이터 길이:', len(documents_list_2))

    all_data = db.get(include=['documents'])
    print('db길이', len( all_data['documents'] ))
    
    # DB 생성 성공 메세지
    print(f'\n\n***** [DataBase( {collection_name} ) is successfully create at  {path}] ***** \n\n')