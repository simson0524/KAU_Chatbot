import csv
import requests
import tempfile
import os

# 서버 URL 설정
url = "http://localhost:3000/data/upload"

# 업로드할 CSV 파일 경로
input_file_path = "crawling/csv_files/crawl_complete_data.csv"

try:
    # 임시 파일 생성
    with tempfile.NamedTemporaryFile(delete=False, mode='w', newline='', encoding='utf-8') as temp_file:
        temp_file_path = temp_file.name

        # CSV 파일 읽기 및 `tag` 필드 제외
        with open(input_file_path, 'r', newline='', encoding='utf-8') as input_file:
            reader = csv.DictReader(input_file)
            # `tag` 필드를 제외한 새로운 필드 정의
            fieldnames = [field for field in reader.fieldnames if field != "tag"]
            writer = csv.DictWriter(temp_file, fieldnames=fieldnames)
            writer.writeheader()  # 헤더 작성

            # 각 행에서 `tag` 필드 제외 후 쓰기
            for row in reader:
                del row["tag"]  # `tag` 필드 제거
                writer.writerow(row)

    # 수정된 CSV 파일 전송
    with open(temp_file_path, 'rb') as file:
        files = {'file': ('modified_contest_data.csv', file)}
        response = requests.post(url, files=files)

    # 서버 응답 확인
    if response.status_code == 200:
        print("파일 업로드 성공!")
        print(response.json())
    else:
        print(f"파일 업로드 실패. 상태 코드: {response.status_code}")
        print(response.text)

finally:
    # 임시 파일 삭제
    if os.path.exists(temp_file_path):
        os.remove(temp_file_path)
