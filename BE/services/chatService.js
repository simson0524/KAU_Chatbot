const chatModel = require('../models/chatModel');
const axios = require('axios');

// 대화 세션을 시작하는 서비스 함수
exports.startChatSession = async (userId) => {
    return await chatModel.createChatSession(userId);
};

// 사용자의 질문을 저장하고 응답을 처리하는 서비스 함수 (대화 ID 포함)
exports.askQuestion = async (sessionId, question) => {
    const response = await chatModel.saveQuestion(sessionId, question);
    return response;
};

// 대화 기록을 조회하는 서비스 함수 (대화 ID 포함)
exports.getChatHistory = async (sessionId) => {
    return await chatModel.getHistory(sessionId);
};

// AI 서버로 메시지를 전달하는 서비스 함수
exports.forwardToAI = async (message) => {
    const aiServerUrl = 'https://ai-server.com/chat'; // 실제 AI 서버 URL로 교체 필요
    const response = await axios.post(aiServerUrl, { message });
    return response.data;
};

exports.generateResponse = async (question) => {
    // 여기에 챗봇 로직을 구현
    return '반가워요!'; // 예시 응답
};

