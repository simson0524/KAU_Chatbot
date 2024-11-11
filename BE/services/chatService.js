const chatModel = require('../models/chatModel');
const axios = require('axios');
const AI_SERVER_URL = "http://ec2-3-36-52-65.ap-northeast-2.compute.amazonaws.com/generate";

// 대화 세션을 시작하는 서비스 함수
exports.startChatSession = async (student_id, chat_character) => {
    try {
        return await chatModel.createChatSession(student_id, chat_character);
    } catch (error) {
        console.error("Error in startChatSession:", error);
        throw error; // 에러를 다시 던져서 호출한 곳에서 처리할 수 있도록
    }
};


// 대화 기록을 조회하는 서비스 함수 (대화 ID 포함)
exports.getFilteredChatHistory = async (student_id, date, content) => {
    try{
        return await chatModel.getFilteredChatHistory(student_id, date, content);
    } catch(error){
        console.error("Error in getFilteredChatHistory:", error);
        throw error;
    }
    
};

// ai서버로 질문 넘겨주고 답변, 태그를 받아오는 함수
exports.generateAIResponse = async (question, character) => {
    try {
        // AI 서버에 질문 보내기
        const aiResponse = await axios.post(AI_SERVER_URL, { query: question, character: character });

        const { answer, tag } = aiResponse.data;

        // AI 서버 응답 반환
        return { answer, tag };
    } catch (error) {
        console.error("Error in generateResponse:", {
            message: error.message,                        // 기본 에러 메시지
            url: AI_SERVER_URL,                            // 요청한 AI 서버 URL
            question,                                      // 요청한 질문
            character,                                     // 캐릭터 정보
            status: error.response?.status || 'No status', // HTTP 상태 코드
            statusText: error.response?.statusText || 'No status text', // 상태 텍스트
            data: error.response?.data || 'No response data' // 응답 데이터
        }); // 에러 로깅 추가
        throw new Error("AI 서버와의 통신에 실패했습니다.");
    }
};

// 태그값 ai서버로 넘겨주고 답변 받아오기
exports.getAIResponse = async (studentId) => {
    // 학생 ID에 해당하는 tags를 DB에서 가져옴
    const tags = await tagModel.getTagsForStudent(studentId);
  
    if (!tags || tags.length === 0) {
      throw new Error('No tags found for this student');
    }
  
    // AI 서버에 tags만 보내기
    const response = await axios.post(aiServerUrl, {
      tags // student_id는 포함시키지 않음
    });
  
    return response.data;
  };