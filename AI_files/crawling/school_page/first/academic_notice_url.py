from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd
import time
from selenium.webdriver.chrome.options import Options

# 셀레니움 드라이버 옵션 설정
options = Options()
options.add_argument("--headless")  # 백그라운드에서 실행
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# 웹드라이버 실행
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# 학사공지 URL 정보
board_urls = {
    "학사공지": "https://www.kau.ac.kr/web/pages/gc14561b.do"
}

# 데이터 저장 함수
def save_to_csv(data, filename):
    df = pd.DataFrame(data, columns=['Title', 'URL'])
    df.to_csv(f"{filename}.csv", index=False, encoding='utf-8-sig')

def crawl_academic_notice():
    # 각 게시판을 순회하면서 데이터 수집
    for board_name, board_url in board_urls.items():
        print(f"크롤링 시작: {board_name}")
        driver.get(board_url)
        time.sleep(3)  # 페이지 로딩 대기

        post_data = []  # 게시글 데이터를 저장할 리스트
        seen_urls = set()  # 중복 URL 확인을 위한 집합
        last_post_url = None  # 이전 페이지의 마지막 게시물의 URL 저장 변수

        # 게시판의 각 페이지를 순회
        while True:
            try:
                # 게시물 목록 로드 대기
                WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, '#notiDfTable tr'))
                )

                # 게시물 정보 추출
                rows = driver.find_elements(By.CSS_SELECTOR, '#notiDfTable tr')

                # 현재 페이지의 마지막 게시물 URL을 저장할 변수
                current_last_post_url = None

                # 각 게시물의 세부 정보 추출
                for row in rows:
                    try:
                        # 제목 링크 찾기
                        title_element = row.find_element(By.CSS_SELECTOR, 'td.tit a')
                        title = title_element.text.strip()  # 제목

                        # onclick 속성 확인
                        onclick_value = title_element.get_attribute('onclick')
                        
                        # onclick 속성이 있는지 확인
                        if onclick_value:
                            # onclick에서 bbsId와 nttId 추출
                            bbsId = onclick_value.split("'")[3]
                            nttId = onclick_value.split("'")[5]

                            # 게시물 URL 생성
                            post_url = f"https://www.kau.ac.kr/web/pages/gc14561b.do?bbsAuth=30&siteFlag=www&bbsFlag=View&bbsId={bbsId}&nttId={nttId}&currentPageNo=&mnuId=gc14561b&returnUrl="
                            
                            # 현재 페이지의 마지막 게시물 URL을 저장
                            current_last_post_url = post_url

                            # 중복 URL 확인 및 저장하지 않음
                            if post_url in seen_urls:
                                print(f"중복된 URL 무시: {post_url}")
                                continue

                            # 중복되지 않은 경우 데이터 추가 및 seen_urls에 추가
                            post_data.append([title, post_url])
                            seen_urls.add(post_url)

                        else:
                            print("onclick 속성이 없음, 건너뜀")

                    except Exception as e:
                        print(f"Error extracting row data: {e}")

                # 이전 페이지의 마지막 게시물 URL과 현재 페이지의 마지막 게시물 URL이 동일하면 크롤링 종료
                if last_post_url == current_last_post_url:
                    print(f"마지막 게시물이 중복됨. 크롤링 종료: {board_name}")
                    break

                # 현재 페이지의 마지막 게시물 URL을 last_post_url에 저장
                last_post_url = current_last_post_url

                # 다음 페이지 버튼 존재 여부 확인 후 클릭
                next_button = driver.find_elements(By.CSS_SELECTOR, 'a.page_next')
                if next_button and next_button[0].get_attribute('onclick') != 'return false;':
                    next_button[0].click()
                    time.sleep(3)  # 페이지 로딩 대기
                else:
                    print(f"크롤링 종료: {board_name}")
                    break

            except Exception as e:
                print(f"Error on board {board_name}: {e}")
                break

        # 수집한 데이터를 CSV로 저장
        save_to_csv(post_data, f"csv_files/{board_name}.csv")

# driver 종료 함수
def close_driver():
    driver.quit()