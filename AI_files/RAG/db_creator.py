from var_config import (TEXT,
                        FILE_DOWNLOAD_URL,
                        ORIGIN_URL,
                        TITLE,
                        PUBLISHED_DATE,
                        DEADLINE_DATE)
import chromadb
import time

def db_creator(embedding_function, documents, collection_name, persist_path):
    # db 정의
    db = chromadb.PersistentClient(path=persist_path)

    collection = db.create_collection(
        name=collection_name,
        embedding_function=embedding_function
    )    

    # 임베딩할 documents를 적당히 나누기 위한 체크포인트
    check_points = len(documents['id']) // 2

    print( check_points )

    sub_documents_1 = documents[TEXT][:check_points]
    sub_ids_1 = documents['id'][:check_points]
    sub_documents_2 = documents[TEXT][check_points:]
    sub_ids_2 = documents['id'][check_points:]

    collection.add(
        documents=sub_documents_1,
        ids=sub_ids_1
    )

    print('-----첫 데이터 추가 완료 및 대기중-----')
    time.sleep(70)
    
    collection.add(
        documents=sub_documents_2,
        ids=sub_ids_2
    )

     # DB 생성 성공 메세지
    print(f'\n\n***** [DataBase( {collection_name} ) is successfully create at  {persist_path}] ***** \n\n')