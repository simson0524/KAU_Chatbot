import pandas as pd
from datetime import datetime, timedelta

# CSV 파일 경로 지정
file_path = 'crawling/csv_files/crawl_complete_data.csv'

# CSV 파일 읽기
data = pd.read_csv(file_path)

# 현재 날짜 설정
today = datetime.today()

# 문자열을 날짜로 변환
data['deadline_date'] = pd.to_datetime(data['deadline_date'], errors='coerce')
data['published_date'] = pd.to_datetime(data['published_date'], errors='coerce')

# 삭제할 인덱스 저장 리스트
drop_indices = []

# 각 행을 순회하며 조건을 체크
for index, row in data.iterrows():
    if pd.notna(row['deadline_date']):
        # deadline_date가 현재 날짜보다 이전이면 삭제 대상
        if row['deadline_date'] < today:
            drop_indices.append(index)
    else:
        # deadline_date가 없을 때 published_date가 120일 이전이면 삭제 대상
        if pd.notna(row['published_date']) and row['published_date'] < today - timedelta(days=120):
            drop_indices.append(index)

# 삭제 대상 인덱스를 제거한 새로운 DataFrame 생성
filtered_data = data.drop(drop_indices)

# 결과를 새로운 CSV 파일로 저장
filtered_data.to_csv('crawling/csv_files/del_deadline_data.csv', index=False, encoding='utf-8-sig')