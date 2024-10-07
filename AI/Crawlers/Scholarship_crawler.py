
# 드림스폰 사이트에서 일반장학금정보 크롤링

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from tqdm import tqdm
import chromedriver_autoinstaller
import time
import pandas as pd
import requests
import random

# 로그인 정보 입력시 인간처럼 보이게 하기 위해
def natural_typing(element, text):
    for char in text:
        element.send_keys(char)
        time.sleep(random.uniform(0.1, 0.4))

# ChromeDriver 자동설치(with pip install chromedriver-autoinstaller)
chromedriver_autoinstaller.install()

# 드림스폰 로그인 하기
SIGNIN_URL = 'https://www.dreamspon.com/member/login.html'
E_MAIL = 'simson0524@kau.kr'
PASSWORD = 'tksgkrvmfhwprxm'

# crawling할 사이트 주소(드림스폰 일반장학금)
CRAWLING_TARGET_URL = ['https://www.dreamspon.com/scholarship/list.html?page=1',
                       'https://www.dreamspon.com/scholarship/list.html?page=2',
                       'https://www.dreamspon.com/scholarship/list.html?page=3',
                       'https://www.dreamspon.com/scholarship/list.html?page=4',
                       'https://www.dreamspon.com/scholarship/list.html?page=5',
                       'https://www.dreamspon.com/scholarship/list.html?page=6',
                       'https://www.dreamspon.com/scholarship/list.html?page=7',
                       'https://www.dreamspon.com/scholarship/list.html?page=8',
                       'https://www.dreamspon.com/scholarship/list.html?page=9',
                       'https://www.dreamspon.com/scholarship/list.html?page=10']

# chrome driver 사용하기
options = webdriver.ChromeOptions()
options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
driver = webdriver.Chrome(options=options)

# 크롤링한 크롤링 대상 url들(a_tag) 저장해 둘 리스트
target_links = []

# 크롤링 할 url들을 results에 긁어모음
try:
    for target_url in CRAWLING_TARGET_URL:
        # 웹페이지 열기
        driver.get(target_url)
        
        # 페이지 로딩 대기
        time.sleep(0.67)

        # 페이지 소스 가져오기
        page_source = driver.page_source

        # BeautifulSoup으로 HTML 파싱
        soup = BeautifulSoup(page_source, 'html.parser')

        # bo_table 클래스를 가진 div 찾기
        bo_table = soup.find('div', class_='bo_table')

        # bo_table 안의 모든 a 태그 가져오기
        a_tags = bo_table.find_all('a')

        for a in a_tags:
            title = a.text.strip()
            link = a['href']
            target_links.append( link )
finally:
    print('크롤링 할 문서 수 :', len( target_links ))
    driver.quit()

# 중복된 문서 삭제(중복된 url 삭제)
target_links = set(target_links)
target_links = list(target_links)

# target_links에 있는 html열어서 긁어올거임
driver = webdriver.Chrome(options=options)

# 로그인 페이지로 이동
driver.get( SIGNIN_URL )
time.sleep(1.06)

# 이메일 입력
email_input = driver.find_element(By.ID, 'mbr_id')
natural_typing(email_input, E_MAIL)
time.sleep(0.985)

# 비밀번호 입력
password_input = driver.find_element(By.ID, 'pwd_in')
natural_typing(password_input, PASSWORD)
time.sleep(2)

# 로그인 버튼 클릭하여 로그인 수행(세션 유지 됨)
login_button = driver.find_element(By.CLASS_NAME, 'btn_login')
login_button.click()


results = {'idx':[],
           'text':[],
           'additional_files':[],
           'img':[],
           'deadline_date':[]}

for i, link in enumerate( tqdm(target_links, desc='Current Process : 드림스폰 일반장학금') ):
    driver.get( 'https://www.dreamspon.com' + link )
    time.sleep(random.uniform(2, 60))

    # 고유 인덱스
    idx = '드림스폰_일반장학금_' + str( len(target_links)-i-1 )

    # 공지 본문(텍스트) 추출하기
    content_info_element = WebDriverWait(driver, 60).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".content_info"))
    )
    text = content_info_element.get_attribute('outerHTML')  # HTML 코드를 가져옴

    # 공지 이미지 추출하기
    image_url = None

    # 공지 첨부파일 추출하기
    file_link_element = WebDriverWait(driver, 60).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".btn_file_down"))
    )
    additional_file = file_link_element.get_attribute('data-filepath')  # 다운로드 경로 크롤링

    # 마감일자 추출하기(근데 임시로 모집기간)
    application_period_element = WebDriverWait(driver, 60).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".day p"))
    )
    application_period = application_period_element.text  # 신청 기간 텍스트 크롤링

    # 결과 저장
    results['idx'].append( idx )
    results['text'].append( text )
    results['additional_files'].append( additional_file )
    results['img'].append( image_url )
    results['deadline_date'].append( application_period )

driver.quit()

# 드림스폰 일반장학금 정보 데이터프레임
Dreamspon_scholarship_df = pd.DataFrame( results )

## TODO
'''
크롤링 된 정보들 전처리
'''

Dreamspon_scholarship_df.to_csv('드림스폰 일반장학금.csv',
                                index=False,
                                encoding='utf-8-sig')