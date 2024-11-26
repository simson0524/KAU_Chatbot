const db = require('../config/dbConfig');

// 학교 공지 목록 조회
exports.getSchoolNotices = async () => {
    const [notices] = await db.query(`
        SELECT idx, title, published_date 
        FROM school_notice 
        ORDER BY published_date DESC
        LIMIT 50
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

// 외부 공지 목록 조회
exports.getExternalNotices = async () => {
    const [notices] = await db.query(`
        SELECT idx, title, deadline_date 
        FROM external_notice 
        ORDER BY deadline_date ASC
        LIMIT 50
    `);
    return notices;
};

// 외부 공지 상세 조회
exports.getExternalNoticeDetail = async (idx) => {
    const [notice] = await db.query(`
        SELECT idx, title, text, deadline_date 
        FROM external_notice 
        WHERE idx = ?
    `, [idx]);
    return notice[0];
};