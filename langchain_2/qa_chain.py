from langchain_chroma import Chroma
from langchain.prompts import ChatPromptTemplate
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import create_retrieval_chain
from langchain_openai import ChatOpenAI
"""
[RAG using LangChain - 4] QA chain 설정하기

실제 RAG 시스템의 틀을 구현한 qa_chain함수를 정의한 py파일입니다.
"""
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
    LANGUAGE = 'japanese'

    if character == 'maha':
        LANGUAGE = 'korean'
    elif character == 'mile':
        LANGUAGE = 'english'
    elif character == 'feet':
        LANGUAGE = 'chinese'


    # prompt customizing template
    system_prompt = (
        "Follow these instructions precisely and only answer using the context provided."
        f"Your answer must be strictly in {LANGUAGE}."
        "Do not add any external information or personal assumptions. Only use the facts stated in the context."
        "\n\n"
        "Context: {context}"
    )

    prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
    )
    
    QA_chain = create_stuff_documents_chain(
        llm=llm,
        prompt=prompt
    )
    chain = create_retrieval_chain(retriever, QA_chain)

    # LangChain이 생성한 답변
    result = chain.invoke({"input": query})
    result = result["answer"]

    return result



from db_loader import db_loader
from var_config import (EMBEDDING_FUNCTION,
                        COLLECTION_NAME,
                        LOCAL_DB_PATH,
                        EXTERNAL_DB_URL,
                        MODEL_NAME)
vector_store = db_loader(
    embedding_function=EMBEDDING_FUNCTION,
    collection_name=COLLECTION_NAME,
    path=LOCAL_DB_PATH,
    db_server_url=EXTERNAL_DB_URL
    )
query = "학교에서 진행중인 행사 목록을 말해줘"
character = "maha"

answer = qa_chain(character=character,
                    query=query,
                    vector_store=vector_store)

print(answer)