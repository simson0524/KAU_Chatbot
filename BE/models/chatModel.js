const db = require('../config/dbConfig');
const { nanoid } = require('nanoid');

// 새로운 대화 세션을 생성하는 함수
exports.createChatSession = async (student_id, chat_character) => {
    try {
        // 동일한 학번, 캐릭터에 대한 기존 채팅방 찾기
        const [existingChatRoom] = await db.query(
            'SELECT chat_id FROM chat_room WHERE student_id = ? AND chat_character = ?',[student_id, chat_character]
        );

        // 기존 채팅방이 있는 경우, 해당 채팅방 ID 반환
        if (existingChatRoom.length > 0) {
            console.log("Existing Chat Room Found: ", existingChatRoom[0].chat_id);
            return existingChatRoom[0].chat_id;
        }

        // 새로운 채팅방 생성
        const chatId = nanoid();
        console.log("Generated Chat ID:", chatId);
        const [result] = await db.query('INSERT INTO chat_room (chat_id, student_id, chat_character) VALUES (?, ?, ?)', [chatId, student_id, chat_character]);

        console.log("Database Result:", result);
        return chatId;
    } catch (error) {
        console.error("Error in createChatSession:", error);
        throw error;
    }
};

// 사용자의 질문을 저장하는 함수 (대화 ID 포함)
exports.saveChat = async (chat_id, question, response) => {
    // 질문을 DB에 저장하고 결과를 반환
    const result = await db.query('INSERT INTO message (chat_id, question, response) VALUES (?, ?, ?)', [chat_id, question, response]);
    
    // 성공적으로 저장되면 결과를 반환
    return result[0]; // MySQL2의 경우 결과 배열의 첫 번째 요소가 결과입니다.
};

// 특정 대화 세션의 대화 기록을 조회하는 함수 (대화 ID 포함)
exports.getFilteredHistory = async (conversation_id, date, content) => {
    try {
        // SQL 쿼리에서 날짜와 내용 조건을 추가하여 필터링
        const query = `
            SELECT * FROM chat 
            WHERE conversation_id = ? 
            AND DATE(created_at) = ? 
            AND (question LIKE ? OR response LIKE ?)`;
        
        // '%'를 사용해서 content 부분 매칭을 지원
        const [rows] = await db.query(query, [conversation_id, date, `%${content}%`, `%${content}%`]);
        
        return rows;

    } catch (error) {
        console.error("Error in getFilteredHistory:", error);
        throw error;
    }
    
};
