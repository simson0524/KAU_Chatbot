# 요즘것들 사이트에서 국비교육 정보 크롤링

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

# crawling할 사이트 주소(요즘것들/국비교육)
CRAWLING_TARGET_URL_EDUCATIONS = ['https://www.allforyoung.com/posts/education?order=dday&page=1',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=2',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=3',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=4',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=5',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=6',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=7',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=8',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=9',
                                  'https://www.allforyoung.com/posts/education?order=dday&page=10']

# chrome driver 사용하기
options = webdriver.ChromeOptions()
driver = webdriver.Chrome(options=options)

# 크롤링한 크롤링 대상 url들(a_tag) 저장해 둘 리스트
target_links = []

try:
    for target_url in CRAWLING_TARGET_URL_EDUCATIONS:
        # 웹페이지 열기
        driver.get(target_url)

        # 페이지 로딩 대기
        time.sleep(1.86)

        # 페이지 소스 가져오기
        page_source = driver.page_source

        # BeautifulSoup으로 HTML 파싱
        soup = BeautifulSoup(page_source, 'html.parser')

        # space-y-20 클래스를 가진 div 찾기(요즘것들_국비교육)
        space_20_y = soup.find('div', class_='space-y-20')

        # space-y-20 안의 모든 a 태그 가져오기
        a_tags = space_20_y.find_all('a')

        # 크롤링할 url 패턴 정의
        pattern = re.compile(r"/posts/\d{5}")

        for a in a_tags:
            # title = a.text.strip()
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
           'files':[],
           'URL':[],
           'published_date':[],
           'title':[]}

for i, link in enumerate( tqdm(target_links, desc='Current Process : 요즘것들 국비교육') ):
    driver.get( 'https://www.allforyoung.com' + link )
    time.sleep(2)

    # 고유 인덱스
    idx = '요즘것들_국비교육_'+str(len(target_links)-i-1)

    # 공지 제목 추출
    title = None

    # 공지 본문(텍스트) 추출하기
    text = driver.find_elements(By.CSS_SELECTOR,
                                ".prose.prose-sm.prose-neutral.break-words")
    text = [ul.get_attribute('innerHTML') for ul in text]

    # 공지 이미지 추출하기(학교공지와 다르게 포스터)
    image_url = None
    image_response = None
    
    try:
        meta_tags = driver.find_elements(By.TAG_NAME,
                                         'meta')

        for tag in meta_tags:
            if tag.get_attribute('property') == 'og:image':
                image_url = tag.get_attribute('content')
                break

        if image_url:
            image_response = requests.get(image_url)
    except:
        pass

    # 공지 첨부파일 추출하기
    additional_file = None

    # 마감일자 추출하기
    published_date = None

    # 결과 저장
    results['idx'].append( idx )
    results['text'].append( text )
    results['files'].append( additional_file )
    results['URL'].append( image_url )
    results['published_date'].append( published_date )
    results['title'].append( title )

driver.quit()

# 요즘것들 국비교육 정보 데이터프레임
Yozeumgeotdeul_education_df = pd.DataFrame( results )

## TODO
'''
크롤링 된 정보들 전처리
'''

Yozeumgeotdeul_education_df.to_csv('요즘것들 국비교육.csv',
                                   index=False,
                                   encoding='utf-8-sig')