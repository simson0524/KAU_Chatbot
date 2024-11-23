from langchain.schema import Document
import pandas as pd
import ast
import os
import json
"""
[RAG using LangChain - 1] CSV파일에서 데이터 로드하기

CSV파일에서 데이터를 로드하는 함수 document_loader를 정의한 py파일입니다.

아래 변수들에는 '최종적으로 사용하게 될 csv파일의 열 이름'을 정의해주시면 됩니다.
아래 변수들은 유지보수를 수월히 하기 위해 설정해 두었습니다.
"""
# 'HTML코드와 IMG를 LLM이 분석하여 얻은 텍스트' 열 이름 설정하기
TEXT = 'text'

# '첨부파일' 열 이름 설정하기
FILE_DOWNLOAD_URL = 'files'

# '공고 URL' 열 이름 설정하기
ORIGIN_URL = 'url'

# '제목' 열 이름 설정하기
TITLE = 'title'

# '작성일' 열 이름 설정하기
PUBLISHED_DATE = 'published_date'

# '지원마감일' 열 이름 설정하기
DEADLINE_DATE = 'deadline_date'



def document_loader(csv_file_path):
    """최종적으로 만들어진 csv파일을 LangChain에서 사용할 수 있게 타입을 변환시켜주는 함수

    Args:
        csv_file_path (str): csv파일의 상대경로

    Returns:
        list: Document타입의 정보들(csv에선 행 단위)을 저장한 정보(csv파일 전체)
    """
    global TEXT, FILE_DOWNLOAD_URL, ORIGIN_URL, TITLE, PUBLISHED_DATE, DEADLINE_DATE
    
    data = pd.read_csv(csv_file_path)

    documents = []

    freq_tags_dict = dict()

    for index, row in data.iterrows():
        documents.append(
        Document(
            page_content=str(row[TEXT] if pd.notna(row[TEXT]) else ''),  # 문자열로 변환하여 사용
            metadata={
                FILE_DOWNLOAD_URL: row[FILE_DOWNLOAD_URL] if pd.notna(row[FILE_DOWNLOAD_URL]) else "",
                ORIGIN_URL:        row[ORIGIN_URL] if pd.notna(row[ORIGIN_URL]) else "",
                TITLE:             row[TITLE] if pd.notna(row[TITLE]) else "",
                PUBLISHED_DATE:    row[PUBLISHED_DATE] if pd.notna(row[PUBLISHED_DATE]) else "",
                DEADLINE_DATE:     row[DEADLINE_DATE] if pd.notna(row[DEADLINE_DATE]) else "",
                'tags':            row['tag'] if pd.notna(row['tag']) else ""
            }
            )
        )

        # 빈출 tag정보 추출하기
        curr_tags = ast.literal_eval(row['tag'])
        for tag in curr_tags:
            if tag in freq_tags_dict:
                freq_tags_dict[tag] += 1
            else:
                freq_tags_dict[tag] = 1

    # 출현 횟수가 5번 이상인 것들
    freq_tags = [key for key, value in freq_tags_dict.items() if value >= 5]

    # 빈출 tag정보 저장하기
    filename = "freq_tag.json"
    if os.path.exists(filename):
        os.remove(filename)
    with open(filename, 'w', encoding='utf-8') as file:
        json.dump(freq_tags, file, ensure_ascii=False)

    return documents