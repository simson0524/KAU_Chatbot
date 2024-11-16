const db = require('../config/dbConfig');

// 모든 문의 조회
exports.getAllInquiries = async () => {
  const [rows] = await db.query(`
    SELECT 
      i.inquiry_id, i.student_id, i.title, i.content, 
      d.department_name, i.created_at 
    FROM inquiry_board i
    LEFT JOIN department d ON i.department_id = d.department_id
    ORDER BY i.created_at DESC
  `);
  return rows;
};

// 특정 문의 조회
exports.getInquiryById = async (inquiry_id) => {
  const [rows] = await db.query(`
    SELECT 
      i.inquiry_id, i.student_id, i.title, i.content, 
      d.department_name, i.created_at 
    FROM inquiry_board i
    LEFT JOIN department d ON i.department_id = d.department_id
    WHERE i.inquiry_id = ?
  `, [inquiry_id]);
  return rows[0];
};

// 문의 생성
exports.createInquiry = async (student_id, title, content, department_id) => {
  const [result] = await db.query(`
    INSERT INTO inquiry_board (student_id, title, content, department_id, created_at)
    VALUES (?, ?, ?, ?, NOW())
  `, [student_id, title, content, department_id]);
  return result.insertId;
};
