# 드림스폰 사이트에서 일반장학금정보 크롤링

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from tqdm import tqdm
from datetime import datetime, timedelta
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

# crawling할 사이트 주소(드림스폰 일반장학금)
CRAWLING_TARGET_URL = ['https://www.dreamspon.com/scholarship/list.html?page=1&ordby=1']

# chrome driver 사용하기
options = webdriver.ChromeOptions()
driver = webdriver.Chrome(options=options)

# 크롤링 할 url들을 results에 긁어모음
try:
    # 웹페이지 열기
    driver.get(CRAWLING_TARGET_URL[0])
    
    # 페이지 로딩 대기
    time.sleep(0.67)

    # 모집중인 공고들의 페이지들 a태그를 갖고 옴
    pager_links = driver.find_elements(By.XPATH, '//div[@class="pager"]//a')

    # 각 a태그의 href 속성 값을 CRAWLING_TARGET_URL에 append
    for link in pager_links:
        sub_link = link.get_attribute('href')
        if sub_link != None:
            CRAWLING_TARGET_URL.append( sub_link )
finally:
    driver.quit()

print(len(CRAWLING_TARGET_URL), CRAWLING_TARGET_URL)

# 중복된 문서 삭제(중복된 url 삭제)
target_links = set(CRAWLING_TARGET_URL)
target_links = list(CRAWLING_TARGET_URL)

# target_links에 있는 html열어서 긁어올거임
driver = webdriver.Chrome(options=options)

results = {'idx':[],
           'text':[],
           'img':[],
           'files':[],
           'url':[],
           'title':[],
           'published_date':[],
           'deadline_date':[]}

# 날짜 변환 함수 정의 (예: '2024년 10월 21일' -> '2024-10-21')
def convert_korean_date(date_str):
    if pd.notna(date_str):
        match = re.search(r'(\d{4})년 (\d{1,2})월 (\d{1,2})일', date_str)
        if match:
            year, month, day = match.groups()
            return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
    return date_str  # 날짜 형식이 아니면 그대로 반환

k = 1

for i, link in enumerate( tqdm(CRAWLING_TARGET_URL, desc='Current Process : 드림스폰 일반장학금') ):
    driver.get( link )

    rows = driver.find_elements(By.CSS_SELECTOR, 'div.bo_table table tbody tr')

    for row in rows:
        # 고유 인덱스
        idx = '드림스폰_일반장학금_' + str( k )
        k += 1

        # 본문 내용 추출(불가능하므로 None)
        text = None

        # 이미지 링크 추출(불가능하므로 None)
        image_url = None

        # 1. title 클래스에서 href와 텍스트 추출
        title_element = row.find_element(By.CSS_SELECTOR, 'td.td_subject p.title a')
        title = title_element.text  # 제목 텍스트

        # 원문 링크 추출
        url = title_element.get_attribute('href')

        # 첨부파일 대신 태그정보 포함
        hashtag_elements = row.find_elements(By.CSS_SELECTOR, 'div.hashtag span')
        hashtags = [hashtag.text for hashtag in hashtag_elements]  # 해시태그 리스트

        # 지원 마감일 추출
        day_element = row.find_element(By.CSS_SELECTOR, 'td.td_day span.count')
        day_text = day_element.text  # 예: "D-2"
        day_text = int(day_text.split('-')[-1])
        today = datetime.today()
        deadline_date = today + timedelta(days=day_text)
        deadline_date = deadline_date.strftime('%Y년 %m월 %d일')
        deadline_date = convert_korean_date(deadline_date)

        # 게시일 추출(불가능하므로 None)
        published_date = None

        # 공지 이미지 추출하기
        image_url = None 

        # 결과 저장
        results['idx'].append( idx )
        results['text'].append( text )
        results['img'].append( image_url )
        results['files'].append( hashtags )
        results['url'].append( url )
        results['title'].append( title )
        results['published_date'].append( published_date )
        results['deadline_date'].append( deadline_date )

        # print('\ntitle :', title, '\nurl :', url, '\nhashtags :', hashtags, '\ndeadline :', deadline_date)



driver.quit()

# 드림스폰 일반장학금 정보 데이터프레임
Dreamspon_scholarship_df = pd.DataFrame( results )

## TODO
'''
크롤링 된 정보들 전처리
'''

Dreamspon_scholarship_df.to_csv('crawling/csv_files/드림스폰 일반장학금.csv',
                                index=False,
                                encoding='utf-8-sig')