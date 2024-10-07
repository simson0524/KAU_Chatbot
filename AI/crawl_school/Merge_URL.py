import pandas as pd
import os

def merge_urls():
    # 통합할 CSV 파일들의 이름 목록
    csv_files = [
        "일반공지.csv", "학사공지.csv", "장학대출공지.csv", "행사공지.csv",
        "모집채용.csv", "전염병_공지사항.csv", "IT공지사항.csv", "산학연구.csv"
    ]

    # 통합된 데이터를 저장할 리스트
    merged_data = []

    # 각 CSV 파일을 읽어들이고 데이터를 통합
    for file in csv_files:
        if os.path.exists(file):
            df = pd.read_csv(file)
            # 각 게시판 종류를 구분할 수 있도록 파일 이름에서 확장자 제거 후 추가
            df['Category'] = os.path.splitext(file)[0]
            merged_data.append(df)
        else:
            print(f"{file} 파일이 존재하지 않습니다.")

    # 모든 데이터를 하나의 DataFrame으로 병합
    merged_df = pd.concat(merged_data, ignore_index=True)

    # 병합된 데이터를 통합 URL 정보 CSV 파일로 저장
    merged_df.to_csv("Merge_URL.csv", index=False, encoding='utf-8-sig')
    print("Merge_URL.csv 파일이 생성되었습니다.")
