from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd
import time
from datetime import datetime, timedelta
from selenium.webdriver.chrome.options import Options

# 셀레니움 드라이버 옵션 설정
options = Options()
options.add_argument("--headless")  # 백그라운드에서 실행
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# 웹드라이버 실행
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# 장학/대출공지 URL 정보
board_urls = {
    "장학대출공지": "https://www.kau.ac.kr/web/pages/gc73650b.do"
}

# 기존 CSV 파일을 읽어와 중복 URL 방지
def load_existing_data(filename):
    try:
        df = pd.read_csv(filename)
        return set(df['URL'].tolist()), df  # 이미 저장된 URL을 중복 방지용으로 활용
    except FileNotFoundError:
        return set(), pd.DataFrame(columns=['Title', 'URL'])  # 파일이 없으면 빈 집합 반환

# 데이터 저장 함수 (새로 추가된 데이터를 기존 파일에 저장)
def save_to_csv(data, filename):
    new_df = pd.DataFrame(data, columns=['Title', 'URL'])
    try:
        existing_df = pd.read_csv(filename)
        updated_df = pd.concat([existing_df, new_df]).drop_duplicates(subset=['URL'])
    except FileNotFoundError:
        updated_df = new_df  # 파일이 없으면 새로운 파일로 저장
    updated_df.to_csv(filename, index=False, encoding='utf-8-sig')


for board_name, board_url in board_urls.items():
    print(f"크롤링 시작: {board_name}")
    driver.get(board_url)
    time.sleep(3)  # 페이지 로딩 대기

    post_data = []  # 새로 추가된 게시글 데이터를 저장할 리스트
    seen_urls, existing_df = load_existing_data(f"csv_files/{board_name}.csv")  # 중복 URL 확인을 위한 기존 데이터
    last_post_url = None  # 이전 페이지의 마지막 게시물의 URL 저장 변수

    # 4달 이내의 날짜 기준
    today = datetime.today()
    last_week = today - timedelta(days=7)

    # 4달 이후 게시물 처리 카운터
    old_post_count = 0

    crawling = True

    # 게시판의 각 페이지를 순회
    while crawling:
        try:
            # 게시물 목록 로드 대기
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, '#bbsDfTable tr'))
            )

            # 게시물 정보 추출
            rows = driver.find_elements(By.CSS_SELECTOR, '#bbsDfTable tr')

            # 현재 페이지의 마지막 게시물 URL을 저장할 변수
            current_last_post_url = None

            # 각 게시물의 세부 정보 추출
            for row in rows:
                try:
                    # 제목 링크 찾기
                    title_element = row.find_element(By.CSS_SELECTOR, 'td.tit')
                    title = title_element.text.strip()  # 제목

                    # 작성일자 추출
                    date_element = row.find_element(By.CSS_SELECTOR, 'td:nth-child(4)').text.strip()
                    post_date = datetime.strptime(date_element, "%Y-%m-%d")

                    # onclick 속성 확인
                    onclick_value = title_element.get_attribute('onclick')

                    # onclick 속성이 있는지 확인
                    if onclick_value:
                        # onclick에서 bbsId와 nttId 추출
                        bbsId = onclick_value.split("'")[3]
                        nttId = onclick_value.split("'")[5]

                        # 게시물 URL 생성
                        post_url = f"https://www.kau.ac.kr/web/pages/gc73650b.do?bbsAuth=30&siteFlag=www&bbsFlag=View&bbsId={bbsId}&nttId={nttId}&currentPageNo=&mnuId=gc73650b&returnUrl="
                        
                        # 현재 페이지의 마지막 게시물 URL을 저장
                        current_last_post_url = post_url

                        # 중복 URL 확인 및 저장하지 않음
                        if post_url in seen_urls:
                            print(f"중복된 URL 무시: {post_url}")
                            old_post_count += 1
                            if old_post_count >= 10:
                                print(f"중복 또는 4달이후 게시물이 {old_post_count}개에 도달. 크롤링 종료: {board_name}")
                                crawling = False
                                break
                            continue

                        # 중복되지 않은 경우 데이터 추가 및 seen_urls에 추가
                        post_data.append([title, post_url])
                        seen_urls.add(post_url)

                        if post_date >= last_week:
                            continue
                        else:
                            # 4달 이후의 게시물 처리
                            print(f"4달 이후의 게시물 처리: {post_url}")
                            old_post_count += 1

                            # 4달 이후의 게시물이 10개 이상이면 종료
                            if old_post_count >= 10:
                                print(f"중복 또는 4달 이후의 게시물이 {old_post_count}개에 도달. 크롤링 종료: {board_name}")
                                crawling = False
                                break

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

            # 4달 이후의 게시물이 10개 이상이면 종료
            if old_post_count >= 10:
                print(f"중복 또는 4달 이후의 게시물이 {old_post_count}개에 도달. 크롤링 종료: {board_name}")
                break

        except Exception as e:
            print(f"Error on board {board_name}: {e}")
            break

    # 수집한 데이터를 CSV로 저장 (중복되지 않는 새로운 데이터만 추가)
    if post_data:
        save_to_csv(post_data, f"crawling/school_page/school_csv/{board_name}.csv")
    else:
        print("새로운 업데이트 정보가 없음")


driver.quit()