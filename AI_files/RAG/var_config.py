from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
client = OpenAI()

### document 로딩 ###
TEXT = 'text'

FILE_DOWNLOAD_URL = 'files'

ORIGIN_URL = 'url'

TITLE = 'title'

PUBLISHED_DATE = 'published_date'

DEADLINE_DATE = 'deadline_date'


### 임베딩 함수 ###
class EmbeddingFunction:
    def __init__(self, model='text-embedding-ada-002'):
        self.model = model

    def __call__(self, input):
        # input이 리스트가 아닌 경우 리스트로 변환
        if not isinstance(input, list):
            input = [input]
        
        # 모든 항목에서 개행 문자를 제거
        input_text = [text.replace("\n", " ") for text in input]
        
        # OpenAI API 호출
        response = client.embeddings.create(input=input_text, model=self.model)
        
        # 여러 임베딩이 반환될 경우 각각의 임베딩을 리스트로 반환
        if len(response.data) > 1:
            return [item.embedding for item in response.data]
        else:
            return response.data[0].embedding
        
# 사용 예시
EMBEDDING_FUNCTION = EmbeddingFunction()


### CSV 파일 경로 설정 ###
CSV_FILE_PATH = "KAU_Chatbot\AI_files\crawling\csv_files\crawl_complete_data.csv"


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