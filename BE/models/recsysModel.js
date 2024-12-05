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

// 알림을 보낼 사용자 조회
exports.getUsersWithInterestNotices = async () => {
    const query = `
      SELECT u.fcm_token
      FROM users u
      INNER JOIN tag_sequence ts ON u.student_id = ts.student_id
      WHERE ts.interest_notice_titles IS NOT NULL
    `;
    const [rows] = await pool.query(query);
    return rows.map((row) => row.fcm_token).filter(Boolean);
  };
