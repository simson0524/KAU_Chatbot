const chatService = require('../services/chatService');
const chatModel = require('../models/chatModel')

// 대화 세션 시작을 처리하는 컨트롤러
exports.startChat = async (req, res) => {

    const { student_id } = req.body;

    try {
        // Step 1: 채팅 세션 시작
        const chatSessionId = await chatService.startChatSession(student_id);

        // Step 2: 환영 메시지 생성 (현재는 하드코딩)
        const welcomeMessage = '환영합니다! 무엇을 도와드릴까요?';

        // 환영 메시지를 클라이언트로 반환
        res.status(200).json({
            conversation_id: chatSessionId,
            student_id: student_id,
            response: welcomeMessage
        });
    } catch (error) {
        res.status(500).json({ error: '채팅 세션 시작에 실패했습니다.' });
    }
};  

// 챗봇에게 질문을 처리하는 컨트롤러 (대화 ID 포함)
exports.askQuestion = async (req, res) => {
    try {
        const { conversation_id } = req.params;
        const { student_id, question } = req.body;

        // 질문에 대한 챗봇 응답 생성
        const response = await chatService.generateResponse(question);

        // 질문과 응답을 데이터베이스에 저장
        await chatModel.saveChat(student_id, question, response);

        // 챗봇 응답 반환
        res.status(200).json({ response });
    } catch (error) {
        console.error("Error in askQuestion:", error); // 에러 로깅 추가
        res.status(500).json({ error: '질문 처리에 실패했습니다.' });
    }
};

// 대화 기록 조회를 처리하는 컨트롤러 (대화 ID 포함)
exports.getChatHistory = async (req, res) => {
    try {
        const { conversation_id } = req.params;
        const history = await chatService.getChatHistory(conversation_id);
        res.status(200).json({ history });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get chat history' });
    }
};

// AI 서버로 메시지를 전달하는 컨트롤러
exports.forwardToAI = async (req, res) => {
    try {
        const aiResponse = await chatService.forwardToAI(req.body.message);
        res.status(200).json({ response: aiResponse });
    } catch (error) {
        res.status(500).json({ error: 'Failed to communicate with AI server' });
    }
};
