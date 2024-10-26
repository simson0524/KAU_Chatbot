import subprocess
import os

subprocess.run(['python', 'crawling/delet/delet_deadline.py'], check=True)

subprocess.run(['python', 'crawling/external_page/Scholarship_crawler.py'], check=True)
subprocess.run(['python', 'crawling/external_page/Yozeumgeotdeul_activity_crawler.py'], check=True)
subprocess.run(['python', 'crawling/external_page/Yozeumgeotdeul_contest_crawler.py'], check=True)
subprocess.run(['python', 'crawling/school_page/school_all_crawl.py'], check=True)

subprocess.run(['python', 'crawling/delet/delet_duplicate.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/combin_yozeum.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/dreamspon_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/yozeumgeotdeul_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/school_convert.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/combin_website_csv.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/combin_data_csv.py'], check=True)

# 여러 파일 경로 설정
file_paths = [
    "crawling/csv_files/드림스폰 일반장학금 변환.csv", "crawling/csv_files/드림스폰 일반장학금.csv", "crawling/csv_files/요즘것들 공모전.csv", "crawling/csv_files/요즘것들 대외활동.csv",
    "crawling/csv_files/요즘것들 국비교육.csv", "crawling/csv_files/요즘것들 공지.csv", "crawling/csv_files/요즘것들 공지 변환.csv",
    "crawling/csv_files/요즘것들 항공대 공지.csv", "crawling/csv_files/항공대 공지 변환.csv", "crawling/csv_files/del_deadline_data.csv"
]

# 각 파일 경로를 순차적으로 확인하고 삭제
for file_path in file_paths:
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"{file_path} 파일이 삭제되었습니다.")
    else:
        print(f"{file_path} 파일을 찾을 수 없습니다.")