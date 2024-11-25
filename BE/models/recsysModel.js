const db = require('../config/dbConfig');

exports.getAllUsersWithTags = async () => {
    const query = `
        SELECT u.student_id, COALESCE(ts.tags, '') AS tags
        FROM users u
        LEFT JOIN tag_sequence ts
        ON u.student_id = ts.student_id
    `;
    const [rows] = await db.execute(query);
    return rows;
};