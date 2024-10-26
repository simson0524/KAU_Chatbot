import pandas as pd

# CSV 파일 읽기
df1 = pd.read_csv('crawling/csv_files/crawl_website_data.csv')
df2 = pd.read_csv('crawling/csv_files/del_deadline_data.csv')


# 데이터 병합 (세 파일을 하나로)
merged_df = pd.concat([df1, df2], ignore_index=True)

# 병합된 파일을 CSV로 저장
merged_df.to_csv('crawling/csv_files/crawl_complete_data.csv', index=False, encoding='utf-8-sig')

print("CSV 파일이 성공적으로 병합되었습니다.")