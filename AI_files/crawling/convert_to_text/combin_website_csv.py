import pandas as pd

# CSV 파일 읽기
df1 = pd.read_csv('crawling/csv_files/요즘것들 공지 변환.csv')
df2 = pd.read_csv('crawling/csv_files/드림스폰 일반장학금 변환.csv')
df3 = pd.read_csv('crawling/csv_files/항공대 공지 변환.csv')


# 데이터 병합 (세 파일을 하나로)
merged_df = pd.concat([df1, df2, df3], ignore_index=True)

# 병합된 파일을 CSV로 저장
merged_df.to_csv('crawling/csv_files/crawl_website_data.csv', index=False, encoding='utf-8-sig')

print("CSV 파일이 성공적으로 병합되었습니다.")
