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
exports.getFilteredHistory = async (chat_id, date, content) => {
    try {
        // 기본 쿼리
        let query = `SELECT * FROM message WHERE chat_id = ?`;
        const params = [chat_id]
        
        // 날짜를 입력한 경우 조건 추가
        if (date) {
            query += ` AND DATE(created_at) = ?`;
            params.push(date);
        }
        
        // 내용을 입력한 경우 조건 추가 (질문 / 응답에 포함되는지 확인)
        if (content) {
            query += ` AND (question LIKE ? OR response LIKE ?)`;
            params.push(`%${content}%`, `%${content}%`);
        }
        
        // 쿼리 실행
        const [rows] = await db.query(query, params);
        return rows;

    } catch (error) {
        console.error("Error in getFilteredHistory:", error);
        throw error;
    }
    
};

// 캐릭터 정보 조회
exports.getCharacterById = async (chat_id) => {
    try {
        const query = 'SELECT chat_character FROM chat_room WHERE chat_id = ?';
        const [rows] = await db.execute(query, [chat_id]);

        if (rows.length > 0) {
            return rows[0].chat_character;; // 채팅방 정보 반환 (첫 번째 결과)
        } else {
            return null; // 해당 채팅방이 없으면 null 반환
        }
    } catch (error) {
        console.error("Error in getChatById:", error);
        throw new Error("Database query failed");
    }
};

exports.getStudentIdByChatId = async (chat_id) => {
    try {
        // chat_rooms 테이블에서 student_id 조회 (예시)
        const [rows] = await db.query('SELECT student_id FROM chat_room WHERE chat_id = ?', [chat_id]);

        if (rows.length > 0) {
            return rows[0].student_id; // student_id 반환
        } else {
            throw new Error(`No student found with chat_id: ${chat_id}`);
        }
    } catch (error) {
        console.error("Error in getStudentIdByChatId:", error);
        throw error;
    }
};



exports.saveOrUpdateTags = async (student_id, newTag) => { 
    try {
        // 기존 tags 조회
        const [existingTagsResult] = await db.query(
            'SELECT tags FROM tag_sequence WHERE student_id = ?', 
            [student_id]
        );

        let updatedTags;
        if (existingTagsResult.length > 0) {
            let existingTags = existingTagsResult[0].tags;

            // 기존 태그가 문자열인 경우 JSON 파싱 시도
            if (typeof existingTags === 'string') {
                try {
                    existingTags = JSON.parse(existingTags);
                } catch (error) {
                    console.error("Failed to parse tags as JSON. Converting to JSON array:", error);
                    existingTags = []; // 파싱 실패 시 빈 배열로 초기화
                }
            }

            // 새로운 태그가 기존 태그에 없다면 추가
            if (!existingTags.includes(newTag)) {
                existingTags.push(newTag);
            }
            updatedTags = JSON.stringify(existingTags);
        } else {
            // 기존 태그가 없으면 새로운 태그 배열로 초기화
            updatedTags = JSON.stringify([newTag]);
        }

        // tag_sequence 테이블 업데이트 또는 삽입
        const sql = `
            INSERT INTO tag_sequence (student_id, tags) VALUES (?, ?)
            ON DUPLICATE KEY UPDATE tags = ?
        `;
        const values = [student_id, updatedTags, updatedTags];
        await db.query(sql, values);

    } catch (error) {
        console.error("Error in saveOrUpdateTags:", error);
        throw error;
    }
};
