from langchain_community.vectorstores import Chroma
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
        db_server_url (str, optional): 별도의 DB인스턴스를 활용하는 경우, DB의 URL. Defaults to None.
    """
    half_documents_length = len( documents ) // 2
    
    db1 = Chroma.from_documents(documents=documents[:half_documents_length],
                                           embedding=embedding_function,
                                           collection_name=collection_name+'_1',
                                           persist_directory=f'DB/{collection_name}_1'
                                           )
    
    # 분당 토큰 제한 해결책
    time.sleep(70)
    
    db2 = Chroma.from_documents(documents=documents[half_documents_length:],
                                           embedding=embedding_function,
                                           collection_name=collection_name+'_2',
                                           persist_directory=f'DB/{collection_name}_2'
                                           )

    # DB 생성 성공 메세지
    print('\n\n***** [DataBase( {db_name} ) is successfully create at  {db_path}] ***** \n\n')
