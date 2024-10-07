
const express = require('express');
const router = express.Router();
const chatController = require('../contorllers/chatController');

// 대화 시작
router.post('/chat', chatController.startChat);

// 챗봇에게 질문 (대화 ID 필요)
router.post('/chatbot/conversation/:conversation_id/ask', chatController.askQuestion);

// 대화 기록 조회 (대화 ID 필요)
router.get('/chatbot/conversation/:conversation_id/history', chatController.getChatHistory);

// AI 서버로 메시지 전달 (대화 내용 전달)
router.post('/chatbot/ai', chatController.forwardToAI);

module.exports = router;
