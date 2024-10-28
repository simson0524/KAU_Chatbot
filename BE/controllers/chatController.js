const chatService = require('../services/chatService');
const chatModel = require('../models/chatModel');

    // 대화 세션 시작을 처리하는 컨트롤러
    exports.startChat = async (req, res) => {

        const { student_id, chat_character } = req.body;

        let welcomeMessage;
        switch (chat_character){
            case 'Maha':
                welcomeMessage = '환영합니다! 무엇을 도와드릴까요?';
                break;
            case 'Mile':
                welcomeMessage = 'Welcome! How can I assist you today?'
                break;
            case 'Feet':
                welcomeMessage = '欢迎你！有什么我可以帮您的吗？';
                break;
            default:
                welcomeMessage = '환영합니다! 무엇을 도와드릴까요?';
                break;
        }

        try {
            // 채팅 세션 시작
            const chatSessionId = await chatService.startChatSession(student_id, chat_character);
            console.log("Chat Session ID:", chatSessionId); // chatSessionId 값 확인

            // 환영 메시지를 클라이언트로 반환
            res.status(200).json({
                chat_id: chatSessionId, 
                student_id: student_id,
                chat_character: chat_character,
                response: welcomeMessage
            });
        } catch (error) {
            console.error("Error in startChat:", error); // 에러 로그 추가
            res.status(500).json({ error: '채팅 세션 시작에 실패했습니다.' });
        }
    };  

// 챗봇에게 질문을 처리하는 컨트롤러 (대화 ID 포함)
exports.askQuestion = async (req, res) => {
    try {
        const { chat_id } = req.params;
        const { question } = req.body;

        // chat_id로 채팅방의 캐릭터 정보를 조회
        const character = await chatModel.getCharacterById(chat_id);

        if (!character) {
            return res.status(404).json({ error: "해당 채팅방을 찾을 수 없습니다." });
        }

        const student_id = await chatModel.getStudentIdByChatId(chat_id); // 예시 함수입니다


        // 질문에 대한 챗봇 응답 생성
        const { answer, tag } = await chatService.generateAIResponse(question, character);
        

        // message 테이블에 질문과 응답 저장
        await chatModel.saveChat(chat_id, question, answer);

        // tags 테이블에 태그 저장 또는 업데이트
        await chatModel.saveOrUpdateTags(student_id, tag);

        // 챗봇 응답 반환
        res.status(200).json({ answer, tag });

        
    } catch (error) {
        console.error("Error in askQuestion:", error); // 에러 로깅 추가
        res.status(500).json({ error: '질문 처리에 실패했습니다.' });
    }
};

// 대화 기록 조회를 처리하는 컨트롤러 (대화 ID 포함)
exports.getFilteredChatHistory = async (req, res) => {
    try {
        const { chat_id } = req.params;
        const { date, content } = req.query;
        
        //필터링된 대화 기록을 가져옴
        const history = await chatService.getFilteredChatHistory(chat_id, date, content);

        res.status(200).json({ history });
    } catch (error) {
        console.error("Error in getFilteredChatHistory:", error);
        res.status(500).json({ error: 'Failed to get chat history' });
    }
};

