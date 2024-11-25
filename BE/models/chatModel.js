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

// 사용자의 질문을 저장하는 함수 
exports.saveChat = async ({student_id, question, response, chat_character, created_at }) => {
    const sql = `
        INSERT INTO chat (student_id, question, response, chat_character, created_at)
        VALUES (?, ?, ?, ?, ?)
    `;
    const result = await db.query(sql, [student_id, question, response, chat_character, created_at]);
    return result[0];
};

// 특정 대화 세션의 대화 기록을 조회하는 함수 (대화 ID 포함)
exports.getFilteredChatHistory = async (student_id, date, content) => {
    try {
        // 기본 쿼리와 파라미터 설정
        let query = `SELECT * FROM chat WHERE student_id = ?`;
        const params = [student_id];
        
        // 날짜가 제공된 경우 조건 추가
        if (date) {
            query += ` AND DATE(created_at) = ?`;
            params.push(date);
        }
        
        // 내용이 제공된 경우 조건 추가 (질문 / 응답에 포함되는지 확인)
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


// AI 서버에서 받아온 태그 값 업데이트
exports.saveOrUpdateTags = async (student_id, newTags) => {
    try {
        // 기존 tags 조회
        const [existingTagsResult] = await db.query(
            'SELECT tags FROM tag_sequence WHERE student_id = ?', 
            [student_id]
        );

        let updatedTags = [];
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

            // 기존 태그가 배열로 존재하는 경우 업데이트
            if (Array.isArray(existingTags)) {
                updatedTags = existingTags;
            }
        }

        // newTags가 배열인지 확인하고 개별 태그 추가
        if (Array.isArray(newTags)) {
            newTags.forEach(tag => {
                if (!updatedTags.includes(tag)) {
                    updatedTags.push(tag); // 중복되지 않으면 추가
                }
            });
        } else {
            // newTags가 배열이 아니라면 단일 태그로 처리
            if (!updatedTags.includes(newTags)) {
                updatedTags.push(newTags);
            }
        }

        // 태그를 JSON 문자열로 변환
        const updatedTagsJSON = JSON.stringify(updatedTags);

        // tag_sequence 테이블 업데이트 또는 삽입
        const sql = `
            INSERT INTO tag_sequence (student_id, tags) VALUES (?, ?)
            ON DUPLICATE KEY UPDATE tags = ?
        `;
        const values = [student_id, updatedTagsJSON, updatedTagsJSON];
        await db.query(sql, values);

    } catch (error) {
        console.error("Error in saveOrUpdateTags:", error);
        throw error;
    }
};


// student_id로 태그값 찾기
exports.getTagsForStudent = async (studentId) => {
    const query = 'SELECT tags FROM tag_sequence WHERE student_id = ?';
    const [rows] = await db.execute(query, [studentId]);
  
    if (rows.length > 0) {
      return JSON.parse(rows[0].tags);
    }
    return null;
  };