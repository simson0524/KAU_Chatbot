import pandas as pd

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
    global TEXT, FILE_DOWNLOAD_URL, ORIGIN_URL, TITLE, PUBLISHED_DATE, DEADLINE_DATE
    
    data = pd.read_csv(csv_file_path)

    documents = {
        TEXT:[],
        FILE_DOWNLOAD_URL:[],
        ORIGIN_URL:[],
        TITLE:[],
        PUBLISHED_DATE:[],
        DEADLINE_DATE:[],
        'id':[]
        }
    
    for index, row in data.iterrows():        
        documents[TEXT].append( row[TEXT] if pd.notna(row[TEXT]) else '' )
        documents[FILE_DOWNLOAD_URL].append( row[FILE_DOWNLOAD_URL] if pd.notna(row[FILE_DOWNLOAD_URL]) else "" )
        documents[ORIGIN_URL].append( row[ORIGIN_URL] if pd.notna(row[ORIGIN_URL]) else "" )
        documents[TITLE].append( row[TITLE] if pd.notna(row[TITLE]) else "" )
        documents[PUBLISHED_DATE].append( row[PUBLISHED_DATE] if pd.notna(row[PUBLISHED_DATE]) else "" )
        documents[DEADLINE_DATE].append( row[DEADLINE_DATE] if pd.notna(row[DEADLINE_DATE]) else "" )
        documents['id'].append( str(index) )

    print('문서 수 :', len(documents['id']))

    return documents