from langchain_chroma.vectorstores import Chroma
"""
[RAG using LangChain - 3] DB 불러오기

생성한 DB를 불러오는 db_loader함수를 정의한 py파일입니다.
"""
def db_loader(embedding_function, collection_name, path=None):
    """생성된 DB를 사용하기 위해 불러오는 함수

    Args:
        embedding_function (langchain.embeddings.base.Embeddings): 임베딩함수
        collection_name (str): db 이름
        path (str, optional): 로컬에 저장되어 있는 DB 경로. Defaults to None.

    Returns:
        Chroma: 데이터베이스
    """
    vector_store = None
    
    vector_store = Chroma(
        collection_name=collection_name,
        embedding_function=embedding_function,
        persist_directory=path
    )

    return vector_store