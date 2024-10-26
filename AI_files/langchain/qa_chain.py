from langchain.chains import RetrievalQA
from langchain.llms import OpenAI

"""
[RAG using LangChain - 4] QA chain 설정하기

실제 RAG 시스템의 틀을 구현한 qa_chain함수를 정의한 py파일입니다.
"""
def qa_chain(model_name, query_history, query, vector_store, chain_type='stuff'):
    """user query와 query history를 가지고 document를 retrieve하고 답변을 generate해주는 함수

    Args:
        model_name (str): 사용할 llm 모델명
        query_history (str): 사용자와 AI의 이전 대화기록
        query (str): 사용자의 현재 쿼리
        vector_store (Chroma): 벡터 DB
        chain_type (str, optional): chain type으로 사용할 것. Defaults to 'stuff'.

    Returns:
        str: LangChain이 생성한 답변
    """
    # QA chain 설정(모델명, 체인유형, 검색기)
    QA_chain = RetrievalQA.from_chain_type(
        llm=model_name,
        chain_type=chain_type,
        retriever=vector_store.retriever()
    )

    # 모델에 넣어줄 쿼리는 이전 쿼리 기록과 현재 사용자의 쿼리의 합
    # TODO : 나중에 앱 서버에서 api 요청 날려주는 request객체의 틀과 맞춰서 수정해야 함
    full_query = f"{query_history}\n\nUser: {query}"

    # LangChain이 생성한 답변
    result = QA_chain.run( full_query )

    return result