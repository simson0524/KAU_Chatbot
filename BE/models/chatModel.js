const db = require('../config/dbConfig');

// 새로운 대화 세션을 생성하는 함수
exports.createChatSession = async (userId) => {
    const [result] = await db.query('INSERT INTO chat_sessions (user_id) VALUES (?)', [userId]);
    return result.insertId;
};

// 사용자의 질문을 저장하는 함수 (대화 ID 포함)
exports.saveQuestion = async (sessionId, question) => {
    await db.query('INSERT INTO chat_messages (session_id, message, sender) VALUES (?, ?, ?)', [sessionId, question, 'user']);
    return 'Question saved';
};

// 특정 대화 세션의 대화 기록을 조회하는 함수 (대화 ID 포함)
exports.getHistory = async (sessionId) => {
    const [rows] = await db.query('SELECT * FROM chat_messages WHERE session_id = ?', [sessionId]);
    return rows;
};
