from langchain.embeddings.base import Embeddings
"""
원하는 임베딩 class를 자율 정의하는 파일
"""
# TODO
# Gemini Embedding은 LangChain에서 지원하지 않으므로 custom해야함. 
# 혹은 Custom Embedding class를 별도로 제작할 수 있음
class GoogleEmbeddings(Embeddings):
    def __init__(self):
        self.api_key = 'your_api_key'