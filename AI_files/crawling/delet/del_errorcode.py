import pandas as pd
import re

# CSV 파일 읽기
file_path = "crawling/csv_files/crawl_complete_data.csv"  # CSV 파일 경로
df = pd.read_csv(file_path)

# 정규식 패턴 정의
patterns_to_remove = [
    r"^I'm sorry.*",  # "I'm sorry"로 시작하는 모든 문장
    r"^Error in summarizing.*",  # "Error in summarizing"로 시작하는 모든 문장
    r"^No image available.*"
]

# text 열에서 특정 패턴에 해당하는 문장을 제거
def remove_patterns(text):
    if not isinstance(text, str):  # 문자열이 아닌 경우 그대로 반환
        return text
    for pattern in patterns_to_remove:
        text = re.sub(pattern, "", text, flags=re.MULTILINE)  # 여러 줄에 걸친 텍스트도 처리
    return text.strip()

df['text'] = df['text'].apply(remove_patterns)

# 결과를 저장
df.to_csv(file_path, index=False, encoding='utf-8-sig')

print("에러 문장 제거 완료")