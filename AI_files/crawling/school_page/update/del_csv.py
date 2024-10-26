import os

# 여러 파일 경로 설정
file_paths = [
    "crawling/school_page/school_csv/일반공지.csv", "crawling/school_page/school_csv/학사공지.csv", "crawling/school_page/school_csv/장학대출공지.csv", "crawling/school_page/school_csv/행사공지.csv",
    "crawling/school_page/school_csv/모집채용.csv", "crawling/school_page/school_csv/전염병 공지사항.csv", "crawling/school_page/school_csv/IT공지사항.csv", "crawling/school_page/school_csv/산학연구.csv",
    "crawling/school_page/school_csv/Merge_URL.csv"
]

# 각 파일 경로를 순차적으로 확인하고 삭제
for file_path in file_paths:
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"{file_path} 파일이 삭제되었습니다.")
    else:
        print(f"{file_path} 파일을 찾을 수 없습니다.")
