import pandas as pd
import os

# 삭제 대상 URL을 포함한 del_deadline_data.csv 파일 경로
del_deadline_file = 'crawling/csv_files/del_deadline_data.csv'

# 5개의 CSV 파일 목록
file_list = [
    'crawling/csv_files/드림스폰 일반장학금.csv',
    'crawling/csv_files/요즘것들 대외활동.csv',
    'crawling/csv_files/요즘것들 공모전.csv',
    'crawling/csv_files/요즘것들 국비교육.csv',
    'crawling/csv_files/항공대 공지.csv'
]

# del_deadline_data.csv 파일에서 제거할 URL 리스트 가져오기
del_deadline_data = pd.read_csv(del_deadline_file)
del_urls = del_deadline_data['url'].tolist()

# 각 파일을 순회하며 제거 작업 수행
for file in file_list:
    # 파일 읽기
    data = pd.read_csv(file)
    
    # URL이 del_urls에 포함되지 않은 데이터만 필터링
    filtered_data = data[~data['url'].isin(del_urls)]
    
    # 변경된 데이터를 원래 파일에 덮어쓰기
    filtered_data.to_csv(file, index=False, encoding='utf-8-sig')

print("삭제 작업 완료")
