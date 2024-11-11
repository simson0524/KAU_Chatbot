const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const userService = require('../services/userService');

// 대화 시작
router.post('/start', userService.loginRequired, chatController.startChat);

// 챗봇에게 질문 (대화 ID 필요)
router.post('/ask', userService.loginRequired, chatController.askQuestion);

// 대화 기록 조회 (대화 ID 필요)
router.get('/history/:student_id', userService.loginRequired, chatController.getFilteredChatHistory);

// AI 서버로 메시지 전달 (대화 내용 전달)
//router.post('/chatbot/ai', userService.loginRequired, chatController.forwardToAI);

module.exports = router;
