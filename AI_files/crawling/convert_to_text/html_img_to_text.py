import pandas as pd
import openai


# OpenAI API 키 설정
openai.api_key = 'key'

# 1. HTML 원문 요약 함수
def summarize_html(html_content):
    if pd.isna(html_content) or html_content.strip() == "":
        return "No HTML content available"
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o-mini",  # gpt-4 사용
            messages=[
                {"role": "system", "content": "다음의 html에서 텍스트를 추출해봐. 표는 사용하지 말고 텍스트로 설명해. 시작말과 마무리말은 하지마."},
                {"role": "user", "content": html_content}
            ]
        )
        return response['choices'][0]['message']['content'].strip()
    except Exception as e:
        return f"Error in summarizing: {str(e)}"

# 2. 이미지 설명 요약 함수 (이미지 URL과 텍스트 분리 전달)
def summarize_image(image_url):
    if pd.isna(image_url) or image_url.strip() == "" or image_url.lower() == "없음":
        return "No image available"
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "너는 이미지의 내용을 텍스트로 정리해주는 어시스턴트야"},
                {
                    "role": "user", 
                    "content": [
                        {"type": "text", "text": "아래의 URL에 있는 이미지의 내용을 텍스트로 정리해줘. 한국어로 답변해. 시작말과 마무리말은 생략해."},
                        {"type": "image_url", "image_url": {"url": image_url}}
                    ]
                }
            ]
        )
        return response['choices'][0]['message']['content'].strip()
    except Exception as e:
        return f"Error in summarizing image: {str(e)}"

# 3. CSV 파일 로드
file_path = 'to_text_test.csv'  # 원본 CSV 파일 경로를 입력하세요
df = pd.read_csv(file_path)

# 4. HTML 원문과 이미지 요약 생성
df['HTML 원문 텍스트화'] = df['HTML 원문'].apply(summarize_html)
df['이미지 텍스트화'] = df['이미지'].apply(summarize_image)

# 5. 필요한 열만 선택하여 새로운 데이터프레임 생성
result_df = df[['ID', 'HTML 원문 텍스트화', '이미지 텍스트화', '첨부파일', '제목', '작성일', 'URL']]

# 6. 결과를 새로운 CSV 파일로 저장
output_file_path = 'summary_result.csv'
result_df.to_csv(output_file_path, index=False, encoding='utf-8-sig')

print(f"Summary saved to {output_file_path}")