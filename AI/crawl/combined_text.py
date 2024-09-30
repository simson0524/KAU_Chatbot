import pandas as pd

# CSV 파일 로드
file_path = 'summary_result.csv'  # 실제 CSV 파일 경로로 변경
df = pd.read_csv(file_path)

# 'HTML 원문 텍스트화'와 '이미지 텍스트화'를 통합하는 함수
def combine_html_and_image(html_text, image_text):
    if pd.isna(html_text):
        html_text = ""
    if pd.isna(image_text) or image_text.strip().lower() == "no image available":
        image_text = ""
    return f"{html_text.strip()} {image_text.strip()}".strip()

# '텍스트' 열 생성
df['텍스트'] = df.apply(lambda row: combine_html_and_image(row['HTML 원문 텍스트화'], row['이미지 텍스트화']), axis=1)

# 'HTML 원문 텍스트화'와 '이미지 텍스트화' 열 제거
df.drop(['HTML 원문 텍스트화', '이미지 텍스트화'], axis=1, inplace=True)

# 결과를 새로운 CSV 파일로 저장
output_file_path = 'combined_text_result.csv'
df.to_csv(output_file_path, index=False, encoding='utf-8-sig')

print(f"Updated CSV saved to {output_file_path}")