import os
import openai
from search_DB import search_similar_documents

# OpenAI API 설정
openai.api_key = 'my key'

def get_gpt_response(prompt):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": prompt},
            ],
            temperature=0.5
        )
        return response['choices'][0]['message']['content']
    except Exception as e:
        return f"Error: {str(e)}"

def check_vector_db_exists(demo_version):
    db_path = f'database/vectorDB_{demo_version}'
    return os.path.exists(db_path)

# 벡터 데이터베이스 생성 여부 체크 및 필요시 생성
csv_file_name = 'dataset.csv'  # CSV 파일 경로
demo_version = '0.1'

# if not check_vector_db_exists(demo_version):
#     print(f"벡터 데이터베이스가 생성되어 있지 않습니다. 새로 생성합니다.")
#     create_vector_db(csv_file_name, demo_version)
# else:
#     print(f"벡터 데이터베이스가 이미 존재합니다. 생성 과정을 건너뜁니다.")

# 사용자 질문 처리
while True:
    query_text = input("GPT에게 물어볼 질문을 입력하세요 (종료하려면 'exit' 입력): ")
    if query_text.lower() == 'exit':
        break
    
    # 유사도 검색을 통해 관련 문서 찾기
    n_results = 5  # 검색할 유사 문서 개수
    results = search_similar_documents(query_text, demo_version, n_results=n_results)

    # GPT에게 검색된 문서 기반으로 질문에 대한 답변 요청
    if results and 'documents' in results:
        references = results 
        # "\n".join([f"{i+1}. 제목: {meta['title']}, URL: {meta['url']}, 작성일: {meta['date']}, 첨부파일: {meta['attachments']}" 
        #                        for i, meta in enumerate(results['metadatas'][0])])
        prompt = (f"레퍼런스:\n\n{references}\n\n"
                  f"위 레퍼런스의 내용을 엄격히 따르면서, 다음 질문에 대한 정확하고 구체적인 답변을 제공해 주세요: {query_text}\n"
                  f"레퍼런스에 없는 정보는 추가하지 말고, 각 레퍼런스에서 제공된 정보만 바탕으로 답변을 작성해 주세요."
                  f" 가능한 한 상세하게 설명해 주시고, 모든 정보는 레퍼런스에 기반해야 합니다.")
        gpt_response = get_gpt_response(prompt)
        
        # GPT 응답 출력
        print("\nGPT의 응답:")
        print(gpt_response)
    else:
        print("유사한 문서를 찾을 수 없습니다.")
