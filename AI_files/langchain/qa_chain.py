from langchain_core.prompts.chat import ChatPromptTemplate
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import create_retrieval_chain
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
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
    language = None

    if character == 'maha':
        language = 'Korean'
    elif character == 'mile':
        language = 'English'
    elif character == 'feet':
        language = 'Chinese'

    context = vector_store.similarity_search(query=query, k=1)[0].page_content

    # Prompt Template Customizing
    prompt_template = ChatPromptTemplate([
        ('system', "You must answer the question in {language}. Use the given context to answer the question. Context: {context}"),
    ])

    prompt_value = prompt_template.invoke(
        {
            'language': language,
            'context': context,
        }
    )

    QA_chain = create_stuff_documents_chain(
        llm=llm,
        prompt=prompt_value
    )
    chain = create_retrieval_chain(retriever, QA_chain)

    # LangChain이 생성한 답변
    result = chain.run( query )

    return result