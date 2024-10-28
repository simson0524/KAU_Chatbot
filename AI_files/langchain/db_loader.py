from langchain.vectorstores import Chroma
"""
[RAG using LangChain - 3] DB 불러오기

생성한 DB를 불러오는 db_loader함수를 정의한 py파일입니다.
"""
def db_loader(embedding_function, collection_name, path, db_server_url=None):
    """생성된 DB를 사용하기 위해 불러오는 함수

    Args:
        embedding_function (langchain.embeddings.base.Embeddings): 임베딩함수
        collection_name (str): db 이름
        path (str, optional): 로컬에 저장되어 있는 DB 경로. Defaults to None.
        db_server_url (str, optional): 외부에 저장되어 있는 DB URL. Defaults to None.

    Returns:
        Chroma: 데이터베이스
    """
    vector_store = None
    # 만약 데이터베이스가 외부에 있다면
    if db_server_url:
        vector_store = Chroma(
            collection_name=collection_name,
            embedding_function=embedding_function,
            chroma_server_url=db_server_url
        )
    # 만약 데이터베이스가 로컬에 있다면
    elif path:
        vector_store = Chroma(
            collection_name=collection_name,
            embedding_function=embedding_function,
            persist_directory=path
        )
    return vector_store