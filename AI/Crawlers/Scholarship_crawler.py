# 드림스폰 사이트에서 일반장학금정보 크롤링

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from tqdm import tqdm
import chromedriver_autoinstaller
import time
import pandas as pd
import requests


# ChromeDriver 자동설치(with pip install chromedriver-autoinstaller)
chromedriver_autoinstaller.install()

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

results = {'idx':[],
           'text':[],
           'additional_files':[],
           'img':[],
           'deadline_date':[]}

for i, link in enumerate( tqdm(target_links, desc='Current Process : 드림스폰 일반장학금') ):
    driver.get( 'https://www.dreamspon.com' + link )
    time.sleep(2)

    # 고유 인덱스
    idx = '드림스폰_일반장학금_' + str( len(target_links)-i-1 )

    # 공지 본문(텍스트) 추출하기
    info_table_elements = driver.find_elements(By.CSS_SELECTOR, ".infoTable .ul-wr + ul")
    text = [ul.get_attribute('innerHTML') for ul in info_table_elements]

    # 공지 이미지 추출하기
    image_url = None

    # 공지 첨부파일 추출하기
    file_link_element = driver.find_element(By.CSS_SELECTOR, ".ul-file a.btn_file_down")
    additional_file = file_link_element.get_attribute("href")

    # 마감일자 추출하기(근데 임시로 모집기간)
    application_period_element = driver.find_element(By.CSS_SELECTOR, ".day p")
    deadline = application_period_element.text

    # 결과 저장
    # 결과 저장
    results['idx'].append( idx )
    results['text'].append( text )
    results['additional_files'].append( additional_file )
    results['img'].append( image_url )
    results['deadline_date'].append( deadline )

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