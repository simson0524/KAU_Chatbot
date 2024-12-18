# 요즘것들 사이트에서 대외활동 정보 크롤링

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from tqdm import tqdm
import chromedriver_autoinstaller
import time
import pandas as pd
import requests
import re

# ChromeDriver 자동설치(with pip install chromedriver-autoinstaller)
chromedriver_autoinstaller.install()

# crawling할 사이트 주소(요즘것들/대외활동)
CRAWLING_TARGET_URL_ACTICITIES = ['https://www.allforyoung.com/posts/activity?order=dday&page=1',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=2',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=3',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=4',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=5',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=6',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=7',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=8',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=9',
                                  'https://www.allforyoung.com/posts/activity?order=dday&page=10']

# chrome driver 사용하기
options = webdriver.ChromeOptions()
driver = webdriver.Chrome(options=options)

# 크롤링한 크롤링 대상 url들(a_tag) 저장해 둘 리스트
target_links = []

try:
    for target_url in CRAWLING_TARGET_URL_ACTICITIES:
        # 웹페이지 열기
        driver.get(target_url)

        # 페이지 로딩 대기
        time.sleep(1.01)

        # 페이지 소스 가져오기
        page_source = driver.page_source

        # BeautifulSoup으로 HTML 파싱
        soup = BeautifulSoup(page_source, 'html.parser')

        # space-y-20 클래스를 가진 div 찾기(요즘것들_대외활동)
        space_20_y = soup.find('div', class_='space-y-20')

        # space-y-20 안의 모든 a 태그 가져오기
        a_tags = space_20_y.find_all('a')
        
        # 크롤링할 url 패턴 정의
        pattern = re.compile(r"/posts/\d{5}")

        for a in a_tags:
            link = a['href']
            if pattern.match(link):
                target_links.append( link )
finally:
    print('크롤링 할 문서 수 :', len( target_links ))
    driver.quit()

# 중복된 문서 삭제(중복된 url 삭제)
target_links = set( target_links )
target_links = list( target_links )

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

for i, link in enumerate( tqdm(target_links, desc='Current Process : 요즘것들 대외활동') ):
    driver.get( 'https://www.allforyoung.com' + link )
    time.sleep(2)

    # 공지 제목 추출
    title = driver.find_element(By.XPATH, '//div[@class="space-y-4"]/h2')
    title = title.text

    # 공지 본문(텍스트) 추출하기
    text_elements = driver.find_elements(By.CSS_SELECTOR, 'div.prose.prose-sm.prose-neutral')
    text = [ul.get_attribute('outerHTML') for ul in text_elements]

    # 공지 이미지 추출하기(학교공지와 다르게 포스터)
    image_url_elements = driver.find_elements(By.XPATH, '//figure[@class="relative aspect-poster overflow-hidden rounded-lg border border-neutral-200"]//img')
    image_url = image_url_elements[0].get_attribute('src')
    

    # 공지 첨부파일 추출하기(대신에 태그 넣었습니다^^)
    tags_elements = driver.find_elements(By.CSS_SELECTOR, 'div.flex.items-center.space-x-2 div.inline-flex.items-center')
    tags_raw = [ tag.text for tag in tags_elements ]
    tags = []
    for value in tags_raw:
        row = list(value.split('/'))
        tags += row
    tags = set(tags)
    tags = list(tags)

    # 현재 사이트 url 추출하기
    url = 'https://www.allforyoung.com' + link

    # URL에서 idx 값 추출
    idx_match = re.search(r'/posts/(\d+)', url)  # 정규식을 사용하여 idx 값을 추출
    idx_value = idx_match.group(1)  # 매칭된 idx 값 (예: '7732')
    idx = f"요즘것들_대외활동_{idx_value}"  # 고유 인덱스로 저장

    # 접수마감일자 추출하기
    deadline_date_elements = driver.find_elements(By.XPATH, '//div[contains(@class, "flex items-center space-x-4")]//p')
    period = [element.text for element in deadline_date_elements]
    splited_period = list(period[0].split())
    deadline_date = ' '.join( splited_period[4:7] )

    # 게시일자 추출하기
    published_date = ' '.join( splited_period[0:3] )

    deadline_date = convert_korean_date(deadline_date)
    published_date = convert_korean_date(published_date)
    # 결과 저장
    results['idx'].append( idx )
    results['text'].append( text )
    results['img'].append( image_url )
    results['files'].append( tags )
    results['url'].append( url )
    results['published_date'].append( published_date )
    results['deadline_date'].append( deadline_date )
    results['title'].append( title )

driver.quit()

# 요즘것들 대외활동 정보 데이터프레임
Yozeumgeotdeul_activity_df = pd.DataFrame( results )

## TODO
'''
크롤링 된 정보들 전처리
'''

Yozeumgeotdeul_activity_df.to_csv('crawling/csv_files/요즘것들 대외활동.csv',
                                  index=False,
                                  encoding='utf-8-sig')