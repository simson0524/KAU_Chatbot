const db = require('../config/dbConfig');

// tag_sequence 테이블의 모든 데이터 가져오기
exports.getAllUserTags = async () => {
    try {
        const query = 'SELECT student_id, tags FROM tag_sequence';
        const [rows] = await db.query(query);
        return rows.map(row => ({
            student_id: row.student_id,
            tags: JSON.parse(row.tags)
        }));
    } catch (error) {
        console.error('Error in getAllUserTags:', error);
        throw error;
    }
};

// 특정 유저의 추천 데이터를 업데이트
exports.updateRecommendations = async (student_id, recommended_notifications) => {
    try {
        const query = `
            UPDATE tag_sequence
            SET recommended_notifications = ?
            WHERE student_id = ?
        `;
        const values = [JSON.stringify(recommended_notifications), student_id];
        const [result] = await db.query(query, values);
        return result;
    } catch (error) {
        console.error('Error in updateRecommendations:', error);
        throw error;
    }
};

// 특정 유저의 추천 데이터를 조회
exports.getRecommendations = async (student_id) => {
    try {
        const query = `
            SELECT recommended_notifications
            FROM tag_sequence
            WHERE student_id = ?
        `;
        const [rows] = await db.query(query, [student_id]);
        if (rows.length > 0 && rows[0].recommended_notifications) {
            return JSON.parse(rows[0].recommended_notifications);
        }
        return [];
    } catch (error) {
        console.error('Error in getRecommendations:', error);
        throw error;
    }
};
