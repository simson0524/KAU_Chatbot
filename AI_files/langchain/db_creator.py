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
    documents_length = len( documents )
    print('db 저장될 데이터의 수:', documents_length)
    
    # DB 정의
    db = Chroma(
        collection_name=collection_name,
        embedding_function=embedding_function,
        persist_directory=path
    )

    print('db정의 완료')

    documents_check_points = [ point for point in range(0, documents_length, 50) ] + [documents_length]
    print('documents_chk_pt', documents_check_points)

    for i in range( len(documents_check_points)-1 ):
        print(f"현재 임베딩중인 문서 위치 : {documents_check_points[i]} 부터 {documents_check_points[i+1]}")
        sub_documents = documents[documents_check_points[i]:documents_check_points[i+1]]
        db.add_documents(documents=sub_documents)
        time.sleep(2)

    # 저장된 db 길이 확인
    all_data = db.get(include=['documents'])
    print('저장된 db길이', len( all_data['documents'] ))
    
    # DB 생성 성공 메세지
    print(f'\n\n***** [DataBase( {collection_name} ) is successfully create at  {path}] ***** \n\n')