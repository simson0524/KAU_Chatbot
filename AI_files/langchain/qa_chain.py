from langchain_core.prompts.chat import ChatPromptTemplate
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import create_retrieval_chain
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from datetime import datetime

"""
[RAG using LangChain - 4] QA chain 설정하기

실제 RAG 시스템의 틀을 구현한 qa_chain함수를 정의한 py파일입니다.
"""
load_dotenv()

def qa_chain(query, vector_store, character):
    """user query와 query history를 가지고 document를 retrieve하고 답변을 generate해주는 함수

    Args:
        query (str): 사용자의 현재 쿼리
        vector_store (Chroma): 벡터 DB
        character (str): 페르소나

    Returns:
        str: LangChain이 생성한 답변
    """
    # OpenAI 모델 설정
    llm = ChatOpenAI(model='gpt-4o-mini')

    # 검색기 설정
    retriever = vector_store.as_retriever()

    # 캐릭터에 따른 페르소나 부여(언어)
    prompt = None

    if character == 'maha':
        prompt = "주어진 Context와 오늘날짜를 이용해서 꼭 한국어로 답변을 생성해줘. Context: {context} Today:{today}"
    elif character == 'mile':
        prompt = "You must answer the question in English. Use the given context and today's date to answer the question. Context: {context} Today:{today}"
    elif character == 'feet':
        prompt = "请务必使用给定的Context内容生成中文回复. Context: {context} Today:{today}"

<<<<<<< HEAD
    context = vector_store.similarity_search(query=query, k=3)[0].page_content
=======
    # # 새로운 프롬프트
    # if character == 'maha':
    #     prompt = "문서내용: {context}\n\n사용자가 질문한 내용과 연관 높은 문서들의 내용이야. 사용자의 질문과 가장 관련 높은 문서 내용을 기반으로 답변을 생성해줘. 답변 내용은 반드시 한국어로 생성해주고, 한국어가 아닌 다른언어로 답변하게 되면 너에게 패널티를 줄거야."
    # elif character == 'mile':
    #     prompt = "문서내용: {context}\n\n사용자가 질문한 내용과 연관 높은 문서들의 내용이야. 사용자의 질문과 가장 관련 높은 문서 내용을 기반으로 답변을 생성해줘. 답변 내용은 반드시 영어로 생성해주고, 영어가 아닌 다른언어로 답변하게 되면 너에게 패널티를 줄거야."
    # elif character == 'feet':
    #     prompt = "문서내용: {context}\n\n사용자가 질문한 내용과 연관 높은 문서들의 내용이야. 사용자의 질문과 가장 관련 높은 문서 내용을 기반으로 답변을 생성해줘. 답변 내용은 반드시 중국어로 생성해주고, 중국어가 아닌 다른언어로 답변하게 되면 너에게 패널티를 줄거야."
    

    context = vector_store.similarity_search(query=query, k=3)[0].page_content
>>>>>>> a90d27a093103ff1c8c2bbd26ca7188cd60df151

    # 오늘 날짜
    today = datetime.today()
    today_str = f"오늘은 {today.year}년 {today.month}월 {today.day}일이야."
    
    # Prompt Template Customizing
    prompt_template = ChatPromptTemplate([
        ('system', prompt),
        ('human', '{input}')
    ])

    QA_chain = create_stuff_documents_chain(
        llm=llm,
        prompt=prompt_template
    )
    chain = create_retrieval_chain(retriever, QA_chain)

    # LangChain이 생성한 답변
    result = chain.invoke(
        {
            'context': context,
            'today': today_str,
            'input': query
        }
    )

    return result
