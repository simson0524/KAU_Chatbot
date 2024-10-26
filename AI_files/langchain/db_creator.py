from langchain.vectorstores import Chroma
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
    # db_path에 db_name이라는 이름을 가진 벡터 DB를 생성하여
    vector_store = Chroma.from_documents(documents=documents,
                                         embedding=embedding_function,
                                         collection_name=collection_name,
                                         persist_directory=path
                                         )

    # Document객체들의 정보를 embedding_function을 이용해 임베딩하고 저장해준다
    vector_store.persist()

    # DB 생성 성공 메세지
    print('\n\n***** [DataBase( {db_name} ) is successfully create at  {db_path}] ***** \n\n')
