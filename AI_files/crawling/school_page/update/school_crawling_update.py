import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import re
from datetime import datetime


# 셀레니움 드라이버 옵션 설정
options = Options()
options.add_argument("--headless")  # 백그라운드에서 실행
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# 웹드라이버 실행
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# 파일 경로 설정
merge_url_file = "crawling/school_page/school_csv/Merge_URL.csv"
school_crawling_file = "crawling/csv_files/항공대 공지.csv"

# Merge_URL.csv 불러오기
merge_url_df = pd.read_csv(merge_url_file)

# school_crawling.csv 불러오기, 파일이 없으면 빈 데이터프레임 생성
try:
    school_crawling_df = pd.read_csv(school_crawling_file)
    existing_titles = set(school_crawling_df['제목'].tolist())  # 이미 크롤링한 제목 집합
except FileNotFoundError:
    print(f"{school_crawling_file} 파일을 찾을 수 없습니다. 빈 데이터프레임을 생성합니다.")
    school_crawling_df = pd.DataFrame(columns=['idx','text','img','files','url','title','published_date','deadline_date'])
    existing_titles = set()  # 파일이 없으면 빈 집합

# Merge_URL.csv에서 새로운 제목 확인
new_urls = merge_url_df[~merge_url_df['Title'].isin(existing_titles)]

# 새로운 URL들을 크롤링
new_data = []

for index, row in new_urls.iterrows():
    url = row['URL']
    title = row['Title']
    print(f"새로운 제목의 URL 크롤링 시작: {url}")

    try:
        # URL에서 bbsId와 nttId 추출하여 custom_id 생성
        bbs_id_match = re.search(r'bbsId=(\d+)', url)
        ntt_id_match = re.search(r'nttId=(\d+)', url)

        if bbs_id_match and ntt_id_match:
            bbs_id = bbs_id_match.group(1)
            ntt_id = ntt_id_match.group(1)
            custom_id = f"{bbs_id}{ntt_id}"  # 예: 011953654
        else:
            custom_id = f"ID_{index + 1}"  # 예외 상황에 대비한 기본 ID

        # URL 접속
        driver.get(url)
        wait = WebDriverWait(driver, 10)

        # 페이지 로딩 대기
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "#divViewHeader h4")))

        # 제목, 날짜, 본문 추출
        title = driver.find_element(By.CSS_SELECTOR, "#divViewHeader h4").text
        content = driver.find_element(By.CSS_SELECTOR, "#divViewConts").get_attribute('innerHTML')

        # 게시글 날짜 추출 또는 현재 날짜 저장
        if driver.find_elements(By.CSS_SELECTOR, "#divSideArticle") and \
                driver.find_element(By.CSS_SELECTOR, "#divSideArticle").is_displayed():
            date = driver.find_element(By.CSS_SELECTOR, ".view_info li.date").text.replace("작성일", "").strip()
        else:
            date = datetime.now().strftime("%Y-%m-%d")  # 현재 날짜 저장

        # 이미지 URL 추출
        images = [img.get_attribute('src') for img in driver.find_elements(By.CSS_SELECTOR, "#divViewConts img")]
        images = ', '.join(images) if images else "없음"

        # 첨부파일 추출
        attachments = []
        for link in driver.find_elements(By.CSS_SELECTOR, ".view_info .attatch a"):
            onclick_text = link.get_attribute('onclick')
            if onclick_text:
                parts = onclick_text.split("'")
                if len(parts) > 3:
                    atch_file_id = parts[1]
                    file_sn = parts[3]
                    mnu_id = driver.find_element(By.ID, "mnuId").get_attribute('value') if driver.find_element(By.ID, "mnuId") else None
                    attachment_url = f"https://www.kau.ac.kr/web/bbs/FileDownApi.gen?atchFileId={atch_file_id}&fileSn={file_sn}&mnuId={mnu_id}"
                    attachments.append(attachment_url)
        attachments = ', '.join(attachments) if attachments else "없음"

        # 크롤링 데이터 저장
        new_data.append({
            'idx': custom_id,
            'text': content,
            'img': images,
            'files': attachments,
            'title': title,
            'published_date': date,
            'url' : url,
            'deadline_date' : ""
        })

    except Exception as e:
        print(f"Error while crawling {url}: {e}")
        new_data.append({
            'idx': custom_id,
            'text': "크롤링 실패",
            'img': "크롤링 실패",
            'files': "크롤링 실패",
            'title': title,
            'published_date': "크롤링 실패",
            'url' : url,
            'deadline_date' : ""
        })

# WebDriver 종료
driver.quit()

# 새로운 데이터를 기존 school_crawling.csv에 추가
if new_data:
    new_crawling_df = pd.DataFrame(new_data)
    new_crawling_df.to_csv(school_crawling_file, index=False, encoding='utf-8-sig')
    print(f"새로운 데이터가 school_crawling.csv에 추가되었습니다. 총 {len(new_data)}개의 항목이 추가되었습니다.")
else:
    print("새로운 데이터가 없습니다. 추가할 항목이 없습니다.")
