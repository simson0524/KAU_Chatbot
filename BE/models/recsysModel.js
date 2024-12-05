const db = require('../config/dbConfig');

exports.getAllUsersWithTags = async () => {
    const query = `
        SELECT 
            u.student_id, 
            u.major, 
            COALESCE(ts.tags, '') AS tags
        FROM users u
        LEFT JOIN tag_sequence ts
        ON u.student_id = ts.student_id
    `;
    const [rows] = await db.execute(query);
    return rows;
};


// 기존 데이터를 삭제하는 함수
exports.clearInterestNoticeTitles = async () => {
    const query = `
        UPDATE tag_sequence
        SET interest_notice_titles = NULL
    `;
    await db.execute(query);
};

// 새로운 데이터를 삽입 또는 업데이트하는 함수
exports.saveInterestNoticeTitles = async (students) => {
    const query = `
        INSERT INTO tag_sequence (student_id, interest_notice_titles)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE interest_notice_titles = VALUES(interest_notice_titles)
    `;

    const connection = await db.getConnection(); // 트랜잭션 사용
    try {
        await connection.beginTransaction();

        for (const student of students) {
            const { student_id, interest_notice_titles } = student;

            // interest_notice_titles를 JSON 문자열로 변환
            const interestTitles = JSON.stringify(interest_notice_titles);

            await connection.execute(query, [student_id, interestTitles]);
        }

        await connection.commit(); // 모든 작업 성공 시 커밋
    } catch (error) {
        await connection.rollback(); // 에러 발생 시 롤백
        throw error;
    } finally {
        connection.release(); // 연결 반환
    }
};

// 관심 공지가 있는 사용자 조회
exports.getUsersWithInterests = async () => {
    const query = `
        SELECT 
            ts.student_id, 
            ts.interest_notice_titles
        FROM 
            tag_sequence ts
        WHERE 
            ts.interest_notice_titles IS NOT NULL AND ts.interest_notice_titles != ''
    `;
    const [rows] = await db.execute(query);

    console.log("Database rows:", rows); // 쿼리 결과를 로그로 출력

    return rows.map(row => ({
        student_id: row.student_id,
        interests: row.interest_notice_titles
    }));
};

// 특정 사용자의 FCM 토큰 조회
exports.getFcmToken = async (studentId) => {
    const query = `
        SELECT fcm_token
        FROM users
        WHERE student_id = ?
    `;
    const [rows] = await db.execute(query, [studentId]);
    return rows[0]?.fcm_token || null; // 토큰이 없으면 null 반환
};

