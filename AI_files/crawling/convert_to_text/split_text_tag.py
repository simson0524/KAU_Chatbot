import pandas as pd
import re

# CSV 파일 읽기
df = pd.read_csv('crawling/csv_files/항공대 test 변환.csv')

# text_convert와 img_convert에서 text와 tag 부분을 추출하는 함수 정의
def extract_text_and_tag(text):
    # text 부분 추출
    text_match = re.search(r"text:\s*(.*?)\n\s*tag:", text, re.DOTALL)
    if text_match:
        extracted_text = text_match.group(1).strip()
    else:
        extracted_text = text.strip()
    
    # tag 부분 추출
    tag_match = re.search(r"tag:\s*(\[[^\]]*\])", text)
    if tag_match:
        extracted_tag = eval(tag_match.group(1))  # 리스트로 변환
    else:
        extracted_tag = []
    
    return extracted_text, extracted_tag

# text_convert에서 text와 tag 추출
df['text_convert_text'], df['text_convert_tag'] = zip(*df['text_convert'].apply(extract_text_and_tag))

# img_convert에서 text와 tag 추출
df['img_convert_text'], df['img_convert_tag'] = zip(*df['img_convert'].apply(extract_text_and_tag))

# text 합치기
df['text'] = df['text_convert_text'] + "\n\n" + df['img_convert_text']

# tag 합치기 (중복 제거)
df['tag'] = df['text_convert_tag'] + df['img_convert_tag']
df['tag'] = df['tag'].apply(lambda x: list(set(x)))

# 필요한 열만 남기기
df_result = df[['idx', 'text', 'files', 'url', 'title', 'published_date', 'deadline_date', 'tag']]

# 결과를 CSV로 저장
df_result.to_csv('crawling/csv_files/항공대 test 변환.csv', index=False, encoding='utf-8-sig')