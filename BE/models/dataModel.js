const db = require('../config/dbConfig');

// 학교 공지 목록 조회
exports.getSchoolNotices = async () => {
    const [notices] = await db.query(`
        SELECT idx, title, published_date 
        FROM school_notice 
        ORDER BY published_date DESC
    `);
    return notices;
};

// 학교 공지 상세 조회
exports.getSchoolNoticeDetail = async (idx) => {
    const [notice] = await db.query(`
        SELECT idx, title, text, published_date 
        FROM school_notice 
        WHERE idx = ?
    `, [idx]);
    return notice[0];
};
