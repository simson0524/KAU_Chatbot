import pandas as pd

file_paths = [
    "crawling/csv_files/요즘것들 공지 변환.csv", "crawling/csv_files/항공대 공지 변환.csv", "crawling/csv_files/드림스폰 일반장학금 변환.csv"
]

for file_path in file_paths:
    df = pd.read_csv(file_path)

    # tag 열에서 태그 목록을 최대 5개로 제한
    df['tag'] = df['tag'].apply(lambda x: str(eval(x)[:5]))

    # 변경된 내용을 CSV 파일로 저장 (덮어쓰기)
    df.to_csv(file_path, index=False)

    print("CSV 파일의 모든 tag 열이 5개로 제한되었습니다.")
