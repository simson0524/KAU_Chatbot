from langchain.embeddings import OpenAIEmbeddings
from custom_embeddings import *
from dotenv import load_dotenv

load_dotenv()

### document 로딩 ###
TEXT = 'text'

FILE_DOWNLOAD_URL = 'files'

ORIGIN_URL = 'url'

TITLE = 'title'

PUBLISHED_DATE = 'published_date'

DEADLINE_DATE = 'deadline_date'


### 임베딩 함수 ###
EMBEDDING_FUNCTION = OpenAIEmbeddings(
    model='text-embedding-ada-002'
    )


### CSV 파일 경로 설정 ###
CSV_FILE_PATH = "/Users/jaehyeoksim/무제 폴더/KAU_Chatbot/AI_files/crawling/csv_files/crawl_complete_data.csv"


### DB config 설정 ###
# DB 이름
COLLECTION_NAME = 'vectorDB_1.3'

# 로컬 DB 경로
LOCAL_DB_PATH = f"DB\{COLLECTION_NAME}"

# 외부 DB url
EXTERNAL_DB_URL = None


### LLM API config 설정 ###
# 사용할 llm 모델명
"""
# 가용 모델명
chat_gpt_model_name_list = ('gpt-4o', 'chatgpt-4o-latest', 'gpt-4o-mini',
                            'gpt-4-turbo', 'gpt-3.5-turbo')
gemini_model_name_list = ('gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro')
"""
MODEL_NAME = 'gpt-4o-mini'