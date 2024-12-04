const db = require('../config/dbConfig');

// 모든 문의 조회
exports.getAllInquiries = async (student_id) => {
  const [rows] = await db.query(`
    SELECT 
      i.inquiry_id, i.student_id, i.title, i.content, 
      d.department_name, i.created_at 
    FROM inquiry_board i
    LEFT JOIN department d ON i.department_id = d.department_id
    ORDER BY i.created_at DESC
  `, [student_id]);
  return rows;
};

// 특정 문의와 댓글 조회
exports.getInquiryById = async (inquiry_id) => {
  // 문의 정보 조회
  const [inquiryRows] = await db.query(`
    SELECT 
      i.inquiry_id, i.student_id, u.name AS author_name, 
      i.title, i.content, d.department_name, i.created_at 
    FROM inquiry_board i
    LEFT JOIN department d ON i.department_id = d.department_id
    LEFT JOIN users u ON i.student_id = u.student_id
    WHERE i.inquiry_id = ?
  `, [inquiry_id]);

  const inquiry = inquiryRows[0];

  if (!inquiry) {
    return null; // 문의가 없을 경우 null 반환
  }

  // 해당 문의에 달린 댓글 조회 (부서 이름 포함)
  const [commentRows] = await db.query(`
    SELECT 
      c.content, c.department_id, d.department_name, c.created_at 
    FROM inquiry_comment c
    LEFT JOIN department d ON c.department_id = d.department_id
    WHERE c.inquiry_id = ?
    ORDER BY c.created_at ASC
  `, [inquiry_id]);

  // 문의 정보에 댓글 배열 추가
  inquiry.comments = commentRows;
  return inquiry;
};



// 문의 생성
exports.createInquiry = async (student_id, title, content, department_id) => {
  const [result] = await db.query(`
    INSERT INTO inquiry_board (student_id, title, content, department_id, created_at)
    VALUES (?, ?, ?, ?, NOW())
  `, [student_id, title, content, department_id]);
  return result.insertId;
};

// 모든 부서 조회
exports.getAllDepartments = async () => {
  const [rows] = await db.query(`
    SELECT department_id, department_name 
    FROM department
    ORDER BY department_id ASC
  `);
  return rows;
};

// 특정 문의 삭제
exports.deleteInquiryById = async (inquiry_id, student_id) => {
  const [result] = await db.query(`
    DELETE FROM inquiry_board 
    WHERE inquiry_id = ? AND student_id = ?
  `, [inquiry_id, student_id]);
  return result.affectedRows > 0; // 삭제 성공 여부 반환
};

// inquiry_comment 테이블에 댓글 삽입
exports.addComment = async (inquiry_id, department_id, content) => {
  const [result] = await db.query(`
    INSERT INTO inquiry_comment (inquiry_id, department_id, content, created_at)
    VALUES (?, ?, ?, NOW())
  `, [inquiry_id, department_id, content]);
  return result.insertId; // 새로 생성된 comment_id 반환
};




