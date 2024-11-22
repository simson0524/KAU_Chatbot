import pandas as pd

# CSV 파일 읽기
file_path = "crawling/csv_files/crawl_complete_data.csv"  # CSV 파일 경로
df = pd.read_csv(file_path)

# 제거할 문장 리스트
sentences_to_remove = [
    "I'm sorry, I can't assist with that.",
    "No image available"
]

# text 열에서 특정 문장을 제거
def remove_sentences(text):
    if not isinstance(text, str):  # 문자열이 아닌 경우 그대로 반환
        return text
    for sentence in sentences_to_remove:
        text = text.replace(sentence, "")
    return text.strip()

df['text'] = df['text'].apply(remove_sentences)

# 결과를 저장
df.to_csv(file_path, index=False, encoding='utf-8-sig')

print("에러문장 제거 완료")