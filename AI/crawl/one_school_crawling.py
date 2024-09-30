from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support import expected_conditions as EC

# 셀레니움 드라이버 옵션 설정
options = Options()
options.add_argument("--headless")  # 백그라운드에서 실행
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# 웹드라이버 실행
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
driver.get("https://www.kau.ac.kr/web/pages/gc14561b.do?bbsAuth=30&siteFlag=www&bbsFlag=View&bbsId=0120&nttId=53220&currentPageNo=1&mnuId=gc14561b&returnUrl=")

# 페이지 로딩 대기
wait = WebDriverWait(driver, 10)
wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "#divViewHeader h4")))

# 제목, 날짜, 작성자, 조회수, 본문, 이미지, 첨부파일 추출
title = driver.find_element(By.CSS_SELECTOR, "#divViewHeader h4").text
date = driver.find_element(By.CSS_SELECTOR, ".view_info li.date").text.replace("작성일", "").strip()
author = driver.find_element(By.CSS_SELECTOR, ".view_info li.writer").text.replace("작성자", "").strip()
views = driver.find_element(By.CSS_SELECTOR, ".view_info li.views").text.replace("조회수", "").strip()
content = driver.find_element(By.CSS_SELECTOR, "#divViewConts").get_attribute('innerHTML')

# 이미지 추출
images = [img.get_attribute('src') for img in driver.find_elements(By.CSS_SELECTOR, "#divViewConts img")]

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
            attachments.append({
                'filename': link.text.strip(),
                'url': attachment_url
            })

# 결과 출력
print(f"Title: {title}")
print(f"Date: {date}")
print(f"Author: {author}")
print(f"Views: {views}")
print(f"Content: {content}")
print("Images:", images)
print("Attachments:", attachments)

# 드라이버 종료
driver.quit()
