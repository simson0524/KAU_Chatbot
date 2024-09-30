import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import re

# 셀레니움 드라이버 옵션 설정
options = Options()
options.add_argument("--headless")  # 백그라운드에서 실행
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# 웹드라이버 실행
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# 통합 URL 정보를 담고 있는 CSV 파일 불러오기
url_df = pd.read_csv("Merge_URL_test.csv")

# 크롤링한 데이터를 저장할 리스트
crawled_data = []

# 각 URL에 접근하여 데이터 수집
for index, row in url_df.iterrows():
    url = row['URL']
    print(f"크롤링 시작: {url}")

    try:
        # URL에서 bbsId와 nttId 추출
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
        date = driver.find_element(By.CSS_SELECTOR, ".view_info li.date").text.replace("작성일", "").strip()
        content = driver.find_element(By.CSS_SELECTOR, "#divViewConts").get_attribute('innerHTML')

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
        crawled_data.append({
            'ID': custom_id,
            'HTML 원문': content,
            '이미지': images,
            '첨부파일': attachments,
            '제목': title,
            '작성일': date,
            'URL' : url
        })

    except Exception as e:
        print(f"Error while crawling {url}: {e}")
        crawled_data.append({
            'ID': custom_id,
            'HTML 원문': "크롤링 실패",
            '이미지': "크롤링 실패",
            '첨부파일': "크롤링 실패",
            '제목': "크롤링 실패",
            '작성일': "크롤링 실패",
            'URL': "크롤링 실패"
        })

# WebDriver 종료
driver.quit()

# 데이터프레임으로 변환하여 CSV 파일로 저장
crawled_df = pd.DataFrame(crawled_data)
crawled_df.to_csv("school_crawling_test.csv", index=False, encoding='utf-8-sig')
print("크롤링 완료 및 school_crawling.csv 파일이 생성되었습니다.")