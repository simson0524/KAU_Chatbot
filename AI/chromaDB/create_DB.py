import pandas as pd
import chromadb

def create_vector_db(csv_file_name, demo_version):
    # CSV 파일을 불러와서 데이터프레임으로 변환
    db_path = f'database/vectorDB_{demo_version}'
    collection_name = f'vectorDB_{demo_version}'
    
    # CSV 파일 불러오기
    df = pd.read_csv(csv_file_name)
    
    client = chromadb.PersistentClient(path=db_path)

    # 컬렉션 생성 또는 기존 컬렉션 가져오기
    collection = client.get_or_create_collection(
        name=collection_name,
        metadata={'hnsw:space': 'cosine'}
    )
    index = []
    
    id_data = df['ID'].tolist()
    title_data = df['제목'].tolist()
    date_data = df['작성일'].tolist()
    url_data = df['URL'].tolist()
    attachments_data = df['첨부파일'].tolist()
    text_data = df['텍스트'].tolist()

    index = 0

    for i in range(len(text_data)):
        
        index += 1
        collection.add(
            documents=[text_data[i]],
            ids=[str(id_data[i])],
            metadatas = {
                'title': title_data[i],
                'url': url_data[i],
                'date': date_data[i],
                'attachments': attachments_data[i]  # 첨부파일 메타데이터에 추가
            },
        )

    print(f"벡터 데이터베이스 '{collection_name}'가 '{db_path}'에 생성되었습니다!")

# 사용 예시
csv_file_name = 'dataset.csv'  # CSV 파일 경로를 지정하세요.
demo_version = '0.1'  # 예를 들어 버전을 설정하세요.
create_vector_db(csv_file_name, demo_version)
