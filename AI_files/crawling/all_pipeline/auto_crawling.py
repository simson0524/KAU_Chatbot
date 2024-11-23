import subprocess
import os
from datetime import datetime
import shutil

subprocess.run(['python', 'crawling/delet/delet_deadline.py'], check=True)

subprocess.run(['python', 'crawling/external_page/Scholarship_crawler.py'], check=True)
subprocess.run(['python', 'crawling/external_page/Yozeumgeotdeul_activity_crawler.py'], check=True)
subprocess.run(['python', 'crawling/external_page/Yozeumgeotdeul_contest_crawler.py'], check=True)
subprocess.run(['python', 'crawling/external_page/Yozeumgeotdeul_education_crawler.py'], check=True)
subprocess.run(['python', 'crawling/school_page/school_all_crawl.py'], check=True)

subprocess.run(['python', 'crawling/delet/delet_duplicate.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/combin_yozeum.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/dreamspon_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/yozeumgeotdeul_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/school_convert.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/max_tag.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/combin_website_csv.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/combin_data_csv.py'], check=True)

subprocess.run(['python', 'crawling/delet/del_errorcode.py'], check=True)

# 여러 파일 경로 설정
file_paths = [
    "crawling/csv_files/드림스폰 일반장학금 변환.csv", "crawling/csv_files/드림스폰 일반장학금.csv", "crawling/csv_files/요즘것들 공모전.csv", "crawling/csv_files/요즘것들 대외활동.csv",
    "crawling/csv_files/요즘것들 국비교육.csv", "crawling/csv_files/요즘것들 공지.csv", "crawling/csv_files/요즘것들 공지 변환.csv",
    "crawling/csv_files/항공대 공지.csv", "crawling/csv_files/항공대 공지 변환.csv", "crawling/csv_files/del_deadline_data.csv", "crawling/csv_files/crawl_website_data.csv"
]

today = datetime.now().strftime("%Y-%m-%d")  # 예: '2023-11-09'
destination_folder = f"CSV_files/{today}/"

# 오늘 날짜 폴더가 없으면 생성
if not os.path.exists(destination_folder):
    os.makedirs(destination_folder)

# 각 파일 경로를 순차적으로 확인하고 이동
for file_path in file_paths:
    if os.path.exists(file_path):
        # 파일명 추출
        file_name = os.path.basename(file_path)
        # 이동할 경로 설정
        destination_path = os.path.join(destination_folder, file_name)
        
        # 파일 이동
        shutil.move(file_path, destination_path)
        print(f"{file_path} 파일이 {destination_path}로 이동되었습니다.")
    else:
        print(f"{file_path} 파일을 찾을 수 없습니다.")

subprocess.run(['python', 'data_send/send_csv.py'], check=True)