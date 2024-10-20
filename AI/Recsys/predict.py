import torch

from BERT4Rec_model import BERT4Rec  

def load_model(model, path="bert4rec_model.pth"):
    model.load_state_dict(torch.load(path))
    model.eval()
    print(f"Model loaded from {path}")

def predict(model, input_sequence, device):
    input_sequence = torch.tensor(input_sequence).unsqueeze(0).to(device)  # 배치 차원 추가
    with torch.no_grad():
        outputs = model(input_sequence)  # (1, seq_length, num_items)
    predicted_scores = outputs[0, -1, :]  # 마지막 아이템의 예측 스코어를 가져옴
    predicted_item = torch.argmax(predicted_scores).item()  # 가장 높은 스코어를 갖는 아이템 예측
    return predicted_item

def main():
    # 하이퍼파라미터 설정 (학습 시와 동일해야 함)
    num_items = 10000  # 아이템의 총 개수
    hidden_size = 256
    num_layers = 2
    num_heads = 8
    max_seq_length = 50

    # 모델 생성
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = BERT4Rec(num_items, hidden_size, num_layers, num_heads, max_seq_length).to(device)

    # 저장된 모델 로드
    load_model(model, "bert4rec_model.pth")

    # 입력 시퀀스 예시 (여기서는 랜덤하게 설정, 실제론 사용자 시퀀스를 입력)
    input_sequence = [1, 2, 3, 4, 5] + [0] * (max_seq_length - 5)  # (시퀀스는 max_seq_length만큼 길어야 함)

    # 모델 예측
    predicted_item = predict(model, input_sequence, device)
    print(f"Predicted next item: {predicted_item}")

if __name__ == "__main__":
    main()
