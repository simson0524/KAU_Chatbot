const db = require('../config/dbConfig');


// 해당 아이디의 게시판이 있는지 조회
exports.findBoardById = async (board_id) => {
    const [board] = await db.query('SELECT author, title FROM boards where id = ?', [board_id]);
    return board[0];
}

// 학과 게시판 조회
exports.getMajorBoard = async (major_identifier) => {
    const [boards] = await db.query("SELECT id, author, title, created_at FROM boards where board_type = '학과' and identifier = ?", [major_identifier]);
    return boards;
}

// 학과 게시판 생성
exports.createMajorBoard = async (major_identifier, student_id, title, content) => {
    const [result] = await db.query(
        "INSERT INTO boards (board_type, identifier, author, title, content) VALUES ('학과', ?, ?, ?, ?)",
        [major_identifier, student_id, title, content]
    );
    return result;
}

// 학번 게시판 조회
exports.getStudentBoard = async (student_identifier) => {
    const [boards] = await db.query("SELECT id, author, title, created_at FROM boards where board_type = '학번' and identifier = ?", [student_identifier]);
    return boards;
}

// 학번 게시판 생성
exports.createStudentBoard = async (student_identifier, student_id, title, content) => {
    const [result] = await db.query(
        "INSERT INTO boards (board_type, identifier, author, title, content) VALUES ('학번', ?, ?, ?, ?)",
        [student_identifier, student_id, title, content]
    );
    return result;
}

// 게시판 상세 조회
exports.getDetailBoard = async (board_id) => {
    const [board] = await db.query("SELECT id, author, title, content, created_at, updated_at FROM boards where id = ?", [board_id]);
    return board[0];
}

// 게시판 댓글 가져오기
exports.getComments = async (board_id) => {
    const [board] = await db.query("SELECT id, author, content, created_at, updated_at FROM comments where board_id = ?", [board_id]);
    return board;
}

// 댓글 생성
exports.createComment = async (board_id, student_id, content) => {
    const [result] = await db.query(
        "INSERT INTO comments (board_id, author, content) VALUES (?, ?, ?)",
        [board_id, student_id, content]
    );
    return result;
}

// 게시판 삭제
exports.deleteBoard = async (board_id) => {
    const [result] = await db.query(
        "delete From boards where id = ?",
        [board_id]
    );
    return result;
}

// 게시판 수정
exports.updateBoard = async (board_id, title, content) => {
    const result = await db.query(
        'UPDATE boards SET title = ?, content =? WHERE id = ?',
        [title, content, board_id]
    );
    return result;
}