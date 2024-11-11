const chatService = require('../services/chatService');
const chatModel = require('../models/chatModel');
const db = require('../config/dbConfig');

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
        const { question, chat_character = "마하"} = req.body;
        const student_id = req.user.student_id;

        // 디버깅 로그
        console.log("student_id:", student_id);

        // 질문에 대한 챗봇 응답 생성 (실제 코드)
        const { answer, tag } = await chatService.generateAIResponse(question, chat_character);

        // 테스트용 더미데이터
        //const answer = "This is a sample answer."; // 임의의 답변
        //const tag = "sampleTag2"; // 임의의 태그
        
        // chat 테이블에 질문과 응답 저장 (선택된 캐릭터와 함께 저장)
        await chatModel.saveChat({
            student_id,
            question,
            response: answer,
            chat_character,
            created_at: new Date()
        });

        // tags 테이블에 태그 저장 또는 업데이트
        await chatModel.saveOrUpdateTags(student_id, tag);

        // 챗봇 응답 반환
        res.status(200).json({ answer, tag });

        
    } catch (error) {
        console.error("Error in askQuestion:", error); // 에러 로깅 추가
        res.status(500).json({ error: '질문 처리에 실패했습니다.' });
    }
};

// 대화 기록 조회를 처리하는 컨트롤러
exports.getFilteredChatHistory = async (req, res) => {
    try {
        const student_id = req.user.student_id; // req.user에서 student_id 가져오기
        const { date, content } = req.query;
        
        // 필터링된 대화 기록을 가져옴
        const history = await chatService.getFilteredChatHistory(student_id, date, content);

        res.status(200).json({ history });
    } catch (error) {
        console.error("Error in getFilteredChatHistory:", error);
        res.status(500).json({ error: 'Failed to get chat history' });
    }
};

// recsys 컨트롤러
exports.getAIResponse = async (req, res) => {
    try {
      const studentId = req.user.student_id;
      const answer = await aiService.getAIResponse(studentId);
      res.json({ answer });
    } catch (error) {
      res.status(500).json({ error: 'Error fetching AI response' });
    }
  };

