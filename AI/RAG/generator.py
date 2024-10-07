from chromaDB.search_DB import search_similar_documents
import google.generativeai as genai
import openai
import os

# OpenAI API 설정
OPEN_AI_API_KEY = ''

# Gemini API 설정
GEMINI_API_KEY = ''


# Generator with ChatGPT-4o-mini(종속 대화형)
def chat_with_ChatGPT(vector_db_demo_version, n_results):
    # OpenAI API Key 설정
    openai.api_key = OPEN_AI_API_KEY

    # 대화 기록 생성(messages 처음에 캐릭터별 페르소나 부여해두면 될 듯)
    messages = [{'role': 'system', 'content': '안녕하세요! 어떤걸 도와드릴까요?'}]

    # chatting loop
    try:
        while True:
            # 사용자 질문
            # TODO
            ''' 지금은 input함수로 구현했지만 나중에 api이을때는 올바르게 받아오는 것으로 코드 수정 '''
            user_query = input("input user query")

            # user_query가 있으면 채팅 계속 진행, 없으면 메모리 관리를 위해 messages에 None후 종료
            if user_query:
                # vector DB에서 비슷한 자료 검색
                results = search_similar_documents(query_text=user_query,
                                                   demo_version=vector_db_demo_version,
                                                   n_results=n_results)
                
                # user_query와 비슷한 documents가 있으면
                if results and 'documents' in results:
                    references = results
                    '''
                    제목: {meta['title']}, 
                    URL: {meta['url']}, 
                    작성일: {meta['date']}, 
                    첨부파일: {meta['attachments']}
                    '''
                    prompt = (f"레퍼런스:\n\n{references}\n\n",
                              f"위 레퍼런스의 내용을 엄격히 따르면서, 다음 질문에 대한 정확하고 구체적인 답변을 제공해 주세요: {user_query}\n"
                              f"레퍼런스에 없는 정보는 추가하지 말고, 각 레퍼런스에서 제공된 정보만 바탕으로 답변을 작성해 주세요."
                              f" 가능한 한 상세하게 설명해 주시고, 모든 정보는 레퍼런스에 기반해야 합니다.")
                    # 검색된 레퍼런스 내용 바탕으로 답변 생성하기 위한 message기록 추가
                    messages.append({'role': 'user', 'content': prompt})

                    # response 요청
                    response = openai.ChatCompletion.create(model = 'gpt-4o-mini',
                                                            messages = messages,
                                                            temperature = 0.7,
                                                            max_tokens = 256)
                    
                    # 이후 대화기록은 raw 레퍼런스가 아니라 user_query를 참조하기 위한 프로세스
                    messages.pop()
                    messages.append({'role': 'user', 'content': user_query})
                    
                    # response에서 대답만을 저장
                    chatbot_response = response['choices'][0]['message']['content']

                    # 대화기록에 Chatbot의 대화기록 저장
                    messages.append({"role": "assistant", "content": chatbot_response})

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

                # user_query와 비슷한 documents가 없으면 그냥 답변 생성(별도 대화 저장 없음)
                else:
                    response = openai.ChatCompletion.create(model = 'gpt-4o-mini',
                                                            messages = [
                                                                {'role': 'system', 'content': '안녕하세요! 어떤걸 도와드릴까요?'},
                                                                {"role": "user", "content": user_query}
                                                            ],
                                                            temperature = 0.7,
                                                            max_tokens = 256
                                                            )
                    # response에서 대답만을 저장
                    chatbot_response = response['choices'][0]['message']['content']

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

            # user_query가 없으면 대화 종료로 취급(이후 별도 기준을 잡아도 됨.)
            else:
                messages = None
                break
    except Exception as e:
        print( f"Error: {str(e)}" )


# Generator with ChatGPT-4o-mini(독립 대화형)
def chat_with_ChatGPT_independence_version(vector_db_demo_version, n_results):
    # OpenAI API Key 설정
    openai.api_key = OPEN_AI_API_KEY

    # chatting loop
    try:
        while True:
            # 사용자 질문
            # TODO
            ''' 지금은 input함수로 구현했지만 나중에 api이을때는 올바르게 받아오는 것으로 코드 수정 '''
            user_query = input("input user query")

            # user_query가 있으면 채팅 계속 진행
            if user_query:
                # vector DB에서 비슷한 자료 검색
                results = search_similar_documents(query_text=user_query,
                                                   demo_version=vector_db_demo_version,
                                                   n_results=n_results)
                
                # user_query와 비슷한 documents가 있으면
                if results and 'documents' in results:
                    references = results
                    '''
                    제목: {meta['title']}, 
                    URL: {meta['url']}, 
                    작성일: {meta['date']}, 
                    첨부파일: {meta['attachments']}
                    '''
                    prompt = (f"레퍼런스:\n\n{references}\n\n",
                              f"위 레퍼런스의 내용을 엄격히 따르면서, 다음 질문에 대한 정확하고 구체적인 답변을 제공해 주세요: {user_query}\n"
                              f"레퍼런스에 없는 정보는 추가하지 말고, 각 레퍼런스에서 제공된 정보만 바탕으로 답변을 작성해 주세요."
                              f" 가능한 한 상세하게 설명해 주시고, 모든 정보는 레퍼런스에 기반해야 합니다.")

                    # TODO
                    '''
                    system에 페르소나 넣어주기
                    '''
                    messages = [{'role': 'system', 'content': '안녕하세요! 어떤걸 도와드릴까요?'},
                                {'role': 'user', 'content': prompt}]

                    # response 요청
                    response = openai.ChatCompletion.create(model = 'gpt-4o-mini',
                                                            messages = messages,
                                                            temperature = 0.7,
                                                            max_tokens = 256)
                    
                    # response에서 대답만을 저장
                    chatbot_response = response['choices'][0]['message']['content']

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

                # user_query와 비슷한 documents가 없으면 그냥 답변 생성
                else:
                    response = openai.ChatCompletion.create(model = 'gpt-4o-mini',
                                                            messages = [
                                                                {'role': 'system', 'content': '안녕하세요! 어떤걸 도와드릴까요?'},
                                                                {"role": "user", "content": user_query}
                                                            ],
                                                            temperature = 0.7,
                                                            max_tokens = 256
                                                            )
                    # response에서 대답만을 저장
                    chatbot_response = response['choices'][0]['message']['content']

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

            # user_query가 없으면 대화 종료로 취급(이후 별도 기준을 잡아도 됨.)
            else:
                break
    except Exception as e:
        print( f"Error: {str(e)}" )


# Generator with Gemini-1.5-flash(종속 대화형)
def chat_with_Gemini(vector_db_demo_version, n_results):
    # Google Generative AI API Key 설정
    genai.configure(api_key=GEMINI_API_KEY)

    # 모델 설정(Gemini 1.5 flash) 및 페르소나 부여
    model = genai.GenerativeModel(model_name='gemini-1.5.flash',
                                  system_instruction='You are a chatbot that make and summarize perfect answer with given document')

    # 대화 기록 생성
    chat = model.start_chat(history=[])

    # 채팅 loop
    try:
        while True:
            # 사용자 질문
            # TODO
            ''' 지금은 input함수로 구현했지만 나중에 api이을때는 올바르게 받아오는 것으로 코드 수정 '''
            user_query = input("input user query")

            # user_query가 있으면 계속 진행
            if user_query:
                # vector DB에서 비슷한 document 검색
                results = search_similar_documents(query_text=user_query,
                                                   demo_version=vector_db_demo_version,
                                                   n_results=n_results)
                
                # user_query와 비슷한 documents가 있으면
                if results and 'documents' in results:
                    references = results
                    '''
                    제목: {meta['title']}, 
                    URL: {meta['url']}, 
                    작성일: {meta['date']}, 
                    첨부파일: {meta['attachments']}
                    '''
                    prompt = (f"레퍼런스:\n\n{references}\n\n",
                              f"위 레퍼런스의 내용을 엄격히 따르면서, 다음 질문에 대한 정확하고 구체적인 답변을 제공해 주세요: {user_query}\n"
                              f"레퍼런스에 없는 정보는 추가하지 말고, 각 레퍼런스에서 제공된 정보만 바탕으로 답변을 작성해 주세요."
                              f" 가능한 한 상세하게 설명해 주시고, 모든 정보는 레퍼런스에 기반해야 합니다.")

                    # prompt를 바탕으로 검색된 reference를 추가해 답변 생성 요청 
                    response = chat.send_message( prompt )

                    # response에서 대답만을 저장
                    chatbot_response = response.text

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

                # user_query와 비슷한 documents가 없으면 그냥 답변 생성
                else:
                    # 시스템에 채팅 기록은 안남게 단순 답변 요청
                    response = model.generate_content( user_query )

                    # response에서 대답만을 저장
                    chatbot_response = response.text

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )
            
            # user_query가 없으면 대화종료로 취급(이후 별도 기준 잡아도 됨)
            else:
                break
    except Exception as e:
        print( f"Error: {str(e)}" )
    

# Generator with Gemini-1.5-flash(독립 대화형)
def chat_with_Gemini(vector_db_demo_version, n_results):
    # Google Generative AI API Key 설정
    genai.configure(api_key=GEMINI_API_KEY)

    # 모델 설정(Gemini 1.5 flash) 및 페르소나 부여
    model = genai.GenerativeModel(model_name='gemini-1.5.flash',
                                  system_instruction='You are a chatbot that make and summarize perfect answer with given document')

    # 채팅 loop
    try:
        while True:
            # 사용자 질문
            # TODO
            ''' 지금은 input함수로 구현했지만 나중에 api이을때는 올바르게 받아오는 것으로 코드 수정 '''
            user_query = input("input user query")

            # user_query가 있으면 계속 진행
            if user_query:
                # vector DB에서 비슷한 document 검색
                results = search_similar_documents(query_text=user_query,
                                                   demo_version=vector_db_demo_version,
                                                   n_results=n_results)
                
                # user_query와 비슷한 documents가 있으면
                if results and 'documents' in results:
                    references = results
                    '''
                    제목: {meta['title']}, 
                    URL: {meta['url']}, 
                    작성일: {meta['date']}, 
                    첨부파일: {meta['attachments']}
                    '''
                    prompt = (f"레퍼런스:\n\n{references}\n\n",
                              f"위 레퍼런스의 내용을 엄격히 따르면서, 다음 질문에 대한 정확하고 구체적인 답변을 제공해 주세요: {user_query}\n"
                              f"레퍼런스에 없는 정보는 추가하지 말고, 각 레퍼런스에서 제공된 정보만 바탕으로 답변을 작성해 주세요."
                              f" 가능한 한 상세하게 설명해 주시고, 모든 정보는 레퍼런스에 기반해야 합니다.")

                    # prompt를 바탕으로 검색된 reference를 추가해 답변 생성 요청 
                    response = model.generate_content( prompt )

                    # response에서 대답만을 저장
                    chatbot_response = response.text

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )

                # user_query와 비슷한 documents가 없으면 그냥 답변 생성
                else:
                    # 시스템에 채팅 기록은 안남게 단순 답변 요청
                    response = model.generate_content( user_query )

                    # response에서 대답만을 저장
                    chatbot_response = response.text

                    # 챗봇 답변 출력해보기
                    print( chatbot_response )
            
            # user_query가 없으면 대화종료로 취급(이후 별도 기준 잡아도 됨)
            else:
                break
    except Exception as e:
        print( f"Error: {str(e)}" )