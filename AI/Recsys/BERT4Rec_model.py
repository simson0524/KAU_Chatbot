from transformers import BertModel, BertConfig

import torch
import torch.nn as nn
import torch.nn.functional as F

class BERT4Rec(nn.Module):
    def __init__(self, num_items, hidden_size=256, num_layers=2, num_heads=8, max_seq_length=50, dropout=0.1):
        super(BERT4Rec, self).__init__()
        
        self.num_items = num_items
        self.hidden_size = hidden_size
        self.max_seq_length = max_seq_length

        # BERT 모델 구성 설정
        config = BertConfig(
            vocab_size=num_items,  # 아이템의 개수는 단어 사전 크기와 유사한 역할을 합니다.
            hidden_size=hidden_size,
            num_hidden_layers=num_layers,
            num_attention_heads=num_heads,
            max_position_embeddings=max_seq_length,
            hidden_dropout_prob=dropout,
            attention_probs_dropout_prob=dropout,
        )

        # BERT 모델 생성
        self.bert = BertModel(config)

        # 최종 예측을 위한 레이어
        self.output_layer = nn.Linear(hidden_size, num_items)

    def forward(self, input_ids, attention_mask=None):
        """
        input_ids: (batch_size, seq_length) 형태의 시퀀스 데이터 (아이템 ID로 구성됨)
        attention_mask: (batch_size, seq_length) 마스킹을 위한 텐서
        """

        # BERT 모델을 통해 시퀀스를 인코딩
        outputs = self.bert(input_ids=input_ids, attention_mask=attention_mask)
        sequence_output = outputs.last_hidden_state  # (batch_size, seq_length, hidden_size)

        # 마스크된 시퀀스의 각 아이템에 대해 다음 아이템 예측
        prediction_scores = self.output_layer(sequence_output)  # (batch_size, seq_length, num_items)

        return prediction_scores