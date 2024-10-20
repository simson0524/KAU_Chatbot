const db = require('../config/dbConfig');

// 새로운 대화 세션을 생성하는 함수
exports.createChatSession = async (student_id) => {
    try {
        const [result] = await db.query('INSERT INTO chat (student_id) VALUES (?)', [student_id]);
        return result.insertId;
    } catch (error) {
        console.error("Error in createChatSession:", error);
        throw error; // 에러를 다시 던져서 호출한 곳에서 처리할 수 있도록
    }
};

// 사용자의 질문을 저장하는 함수 (대화 ID 포함)
exports.saveChat = async (student_id, question, response) => {
    // 질문을 DB에 저장하고 결과를 반환
    const result = await db.query('INSERT INTO chat (student_id, question, response) VALUES (?, ?, ?)', [student_id, question, response]);
    
    // 성공적으로 저장되면 결과를 반환
    return result[0]; // MySQL2의 경우 결과 배열의 첫 번째 요소가 결과입니다.
};

// 특정 대화 세션의 대화 기록을 조회하는 함수 (대화 ID 포함)
exports.getHistory = async (sessionId) => {
    const [rows] = await db.query('SELECT * FROM chat_messages WHERE session_id = ?', [sessionId]);
    return rows;
};
