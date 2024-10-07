const chatService = require('../services/chatService');

// 대화 세션 시작을 처리하는 컨트롤러
exports.startChat = async (req, res) => {

    const { student_id, question } = req.body;

    try {

        const response = await chatService.generateResponse(question);

        const chatRecord = await chatModel.saveChat(student_id, question, response);


        res.json({
            conversation_id: chatRecord.insertId,
            student_id: student_id,
            question: question,
            response: response
        });

        // const session = await chatService.startChatSession(req.body.userId);
        res.status(200).json({ message: 'Chat session started', session });
    } catch (error) {
        res.status(500).json({ error: 'Failed to start chat session' });
    }
};  

// 챗봇에게 질문을 처리하는 컨트롤러 (대화 ID 포함)
exports.askQuestion = async (req, res) => {
    try {
        const { conversation_id } = req.params;
        const response = await chatService.askQuestion(conversation_id, req.body.question);
        res.status(200).json({ response });
    } catch (error) {
        res.status(500).json({ error: 'Failed to ask question' });
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
