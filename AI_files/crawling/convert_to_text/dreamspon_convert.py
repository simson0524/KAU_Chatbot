import pandas as pd
import ast
import re

# CSV 파일 읽기
df = pd.read_csv('crawling/csv_files/드림스폰 일반장학금.csv')

# files 열을 tag 열로 변경하고, 불필요한 '#' 제거
df['tag'] = df['files'].apply(lambda x: str(ast.literal_eval(x)).replace('#', '') if pd.notna(x) else '')

# files 열을 빈 값으로 변경
df['files'] = ''

# 날짜 변환 함수 정의 (예: '2024년 10월 21일' -> '2024-10-21')
def convert_korean_date(date_str):
    if pd.notna(date_str):
        match = re.search(r'(\d{4})년 (\d{1,2})월 (\d{1,2})일', date_str)
        if match:
            year, month, day = match.groups()
            return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
    return date_str  # 날짜 형식이 아니면 그대로 반환

# deadline_date와 published_date 열의 날짜 형식 변환
df['deadline_date'] = df['deadline_date'].apply(convert_korean_date)
df['published_date'] = df['published_date'].apply(convert_korean_date)

# 날짜 열을 YYYY-MM-DD 형식으로 변경
df['deadline_date'] = pd.to_datetime(df['deadline_date'], errors='coerce').dt.strftime('%Y-%m-%d')
df['published_date'] = pd.to_datetime(df['published_date'], errors='coerce').dt.strftime('%Y-%m-%d')

# 필요한 열 순서로 재정렬
df = df[['idx', 'text', 'files', 'url', 'title', 'published_date', 'deadline_date', 'tag']]

# 새로운 CSV 파일로 저장
df.to_csv('crawling/csv_files/드림스폰 일반장학금 변환.csv', index=False, encoding='utf-8-sig')

print("변경 완료. 드림스폰 일반장학금 변환.csv 파일이 생성되었습니다.")
