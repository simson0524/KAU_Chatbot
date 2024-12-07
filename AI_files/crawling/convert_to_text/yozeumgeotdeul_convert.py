import pandas as pd
from openai import OpenAI
import re
import os

client = OpenAI(
    api_key = ''
)

# 1. HTML 원문 요약 함수
def summarize_html(html_content):
    if pd.isna(html_content) or html_content.strip() == "":
        return "No HTML content available"
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",  # gpt-4o-mini 사용
            messages=[
                {"role": "system", "content": """주어진 HTML에서 텍스트만 추출해서 내용을 정확하게 작성해. 표는 사용하지 말고 텍스트로 설명해줘. 관련있는 태그도 달아줘. 'text:'로 시작하고, 관련 있는 태그는 'tag:'로 시작하는 형식으로 출력해.
                
                예시:
                text:
                 2024학년도 KAU 교육과정 모니터링단 학생 모집
                 본교 미래교육혁신원에서는 우리 대학의 전공 및 교양 교육과정 전반에 대한 만족도와 요구를 교육 수요자 시각에서 점검하고, 이를 교육과정 개편에 활용하기 위해 <2024 KAU 교육과정 학생 모니터단>을 모집 합니다. 재학생 여러분들의 많은 관심과 신청 바랍니다.
                 1. <KAU 교육과정 모니터링>이란?
                   - 전공 및 교양 교육과정에 대한 학생들의 만족도와 요구사항을 파악하고 장기적 교육과정 개선에 반영을 목적으로 함
                 - 심층설문지를 활용하여 비대면으로 모니터링 실시
                 - 2024-1학기 전공 및 교양 교육과정을 대상으로 모니터링 실시
                 2. 설문 내용 및 방식
                 ...

                
                주의: 시작말과 마무리말을 사용하지 말고 예시처럼 작성해.
                """},
                {"role": "user", "content": html_content}
            ]
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"Error in summarizing: {str(e)}"

import re

def extract_content_from_brackets(text):
    # 대괄호 안에 있는 내용을 추출하는 간단한 방법
    start = text.find("['") + 2  # [' 다음의 시작 위치
    end = text.find("']", start)  # '] 이전의 끝 위치
    
    if start != -1 and end != -1:
        return text[start:end]
    return "No valid content found"

# 3. CSV 파일 로드
file_path = 'crawling/csv_files/요즘것들 공지.csv'  # 원본 CSV 파일 경로를 입력하세요
df = pd.read_csv(file_path)

# 4. HTML 원문과 이미지 요약 생성
df['text_convert'] = df['text'].apply(summarize_html)

# 5. 필요한 열만 선택하여 새로운 데이터프레임 생성
result_df = df[['idx', 'text_convert', 'files', 'url', 'title', 'published_date', 'deadline_date']]

# 6. 결과를 새로운 CSV 파일로 저장
output_file_path = 'crawling/csv_files/요즘것들 공지 변환.csv'
result_df.to_csv(output_file_path, index=False, encoding='utf-8-sig')

print(f"Summary saved to {output_file_path}")



# CSV 파일 읽기
df = pd.read_csv(output_file_path)

# text_convert와 img_convert에서 text와 tag 부분을 추출하는 함수 정의
def extract_text_and_tag(text):
    # text 부분 추출
    text_match = re.search(r"text:\s*(.*?)\n\s*tag:", text, re.DOTALL)
    if text_match:
        extracted_text = text_match.group(1).strip()
    else:
        extracted_text = text.strip()
    
    return extracted_text

# text_convert에서 text와 tag 추출
df['text_convert_text'] = df['text_convert'].apply(extract_text_and_tag)

# files 열에서 태그로 변환
df['tag'] = df['files'].apply(lambda x: eval(x) if isinstance(x, str) else [])

# text 합치기
df['text'] = df['text_convert_text']

# files 열 비우기
df['files'] = ""

# 필요한 열만 남기기
df_result = df[['idx', 'text', 'files', 'url', 'title', 'published_date', 'deadline_date', 'tag']]

# 결과를 CSV로 저장
df_result.to_csv(output_file_path, index=False, encoding='utf-8-sig')