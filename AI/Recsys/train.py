import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import numpy as np
import os

from BERT4Rec_model import BERT4Rec

# 시퀀스 데이터셋을 위한 커스텀 데이터셋 클래스
class SequenceDataset(Dataset):
    def __init__(self, sequences, labels):
        self.sequences = sequences
        self.labels = labels

    def __len__(self):
        return len(self.sequences)

    def __getitem__(self, idx):
        return torch.tensor(self.sequences[idx]), torch.tensor(self.labels[idx])

# 학습 함수 정의
def train_model(model, train_loader, criterion, optimizer, device, num_epochs=10):
    model.train()
    for epoch in range(num_epochs):
        total_loss = 0
        for sequences, labels in train_loader:
            sequences = sequences.to(device)
            labels = labels.to(device)
            
            optimizer.zero_grad()
            
            # 마스크 토큰을 제외한 다른 모든 아이템 예측
            outputs = model(sequences)  # (batch_size, seq_length, num_items)
            loss = criterion(outputs.view(-1, outputs.size(-1)), labels.view(-1))
            
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()

        avg_loss = total_loss / len(train_loader)
        print(f'Epoch [{epoch+1}/{num_epochs}], Loss: {avg_loss:.4f}')

def save_model(model, path="bert4rec_model.pth"):
    torch.save(model.state_dict(), path)
    print(f"Model saved to {path}")

def main():
    # 하이퍼파라미터 설정
    num_items = 10000  # 아이템의 총 개수
    hidden_size = 256
    num_layers = 2
    num_heads = 8
    max_seq_length = 50
    batch_size = 32
    num_epochs = 10
    learning_rate = 0.001

    # 시퀀스 데이터 (예시로 랜덤 데이터 사용, 실제론 사용자-아이템 상호작용 데이터 사용)
    sequences = np.random.randint(1, num_items, (1000, max_seq_length))  # (1000개의 시퀀스, 각 시퀀스는 50길이)
    labels = np.random.randint(1, num_items, (1000, max_seq_length))  # (각 시퀀스의 라벨, 마스크 예측)

    # 데이터셋과 데이터 로더
    dataset = SequenceDataset(sequences, labels)
    train_loader = DataLoader(dataset, batch_size=batch_size, shuffle=True)

    # 모델 생성
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = BERT4Rec(num_items, hidden_size, num_layers, num_heads, max_seq_length).to(device)

    # 손실 함수와 최적화 알고리즘
    criterion = nn.CrossEntropyLoss(ignore_index=0)  # 마스킹된 위치는 무시
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    # 모델 학습
    train_model(model, train_loader, criterion, optimizer, device, num_epochs)

    # 모델 저장
    save_model(model, "bert4rec_model.pth")

if __name__ == "__main__":
    main()