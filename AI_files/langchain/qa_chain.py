from langchain_core.prompts.chat import ChatPromptTemplate
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import create_retrieval_chain
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
import ast

"""
[RAG using LangChain - 4] QA chain 설정하기

실제 RAG 시스템의 틀을 구현한 qa_chain함수를 정의한 py파일입니다.
"""
load_dotenv()

def cn_trans(chinese_query):
    """Translate Chinese query to Korean using OpenAI model."""
    llm = ChatOpenAI(model='gpt-4o-mini')  # OpenAI LLM instance

    # Translation prompt
    prompt = f"Translate the following Chinese text to Korean. Provide only the translated text without any additional comments or explanations:\n\n{chinese_query}"

    # Perform the translation
    response = llm.predict(prompt)
    return response.strip()

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

    # if character == 'maha':
    #     prompt = "주어진 Context와 오늘날짜를 이용해서 꼭 한국어로 답변을 생성해줘. Context: {context}"
    # elif character == 'mile':
    #     prompt = "You must answer the question in English. Use the given context and today's date to answer the question. Context: {context}"
    # elif character == 'feet':
    #     prompt = "请务必使用给定的Context内容生成中文回复. Context: {context}"

    # 새로운 프롬프트
    if character == 'maha':
        prompt = (
            "사용자가 질문한 내용에 대해 답변을 생성해줘. 답변을 생성할 때는 다음의 조건을 반드시 따라야 해:\n"
            "1. 질문과 가장 관련 있는 문서의 내용만 사용해.\n"
            "2. 질문과 관련 없는 문서의 내용은 절대 사용하지 마.\n"
            "3. 주어진 문서들에 없는 내용은 절대 생성하지 마.\n"
            "4. 답변은 반드시 한국어로 작성해야 해.\n\n"
            "문서내용: {context}"
        )
    elif character == 'mile':
        prompt = (
            "Generate an answer to the user's question. When generating the answer, strictly follow these rules:\n"
            "1. Use only the content from the documents that is most relevant to the question.\n"
            "2. Do not use any irrelevant document content.\n"
            "3. Do not generate information that is not present in the documents.\n"
            "4. The answer must be written in English.\n\n"
            "Document content: {context}"
        )
    elif character == 'feet':
        prompt = (
            "请根据用户的问题生成答案。生成答案时，请严格遵循以下规则：\n"
            "1. 仅使用与问题最相关的文档内容。\n"
            "2. 不要使用与问题无关的文档内容。\n"
            "3. 请勿生成文档中不存在的信息。\n"
            "4. 答案必须用中文书写。\n\n"
            "文档内容: {context}"
        )
    
    # 중국어 쿼리 번역 (feet의 경우만 적용)
    if character == 'feet':
        query = cn_trans(query)  # 중국어 -> 한국어 번역

    results = vector_store.similarity_search(query=query, k=3)

    context = [ result.page_content for result in results ]
    context = '\n\n-----------------------------\n'.join(context)

    tags = []
    for result in results:
        curr_tags = result.metadata.get('tags', '[]')
        curr_tags = ast.literal_eval(curr_tags)
        tags += curr_tags
    tags = set(tags)
    tags = list(tags)
    

    print(f'asfldkjasldkfjsalkdj이거 테스트용임!!!{context}')
    
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
            'input': query
        }
    )

    return result, tags
