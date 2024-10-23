// userModel.js
// 사용자 정보를 저장하고 관리하는 DB 모델

const db = require('../config/dbConfig');

// DB에 입력된 이메일의 사용자가 있는지 확인
exports.findUserByEmail = async (email) => {
    const [users] = await db.query('SELECT * FROM users where email = ?', [email]);
    return users[0];
}

// DB에 입력된 학번의 사용자가 있는지 확인
exports.findUserByStudentId = async (student_id) => {
    const [users] = await db.query('SELECT * FROM users where student_id = ?', [student_id]);
    return users[0];
}

// refresh Token을 DB에 저장
exports.saveRefToken = async (email, refreshToken) => {

}

// DB에 입력한 사용자 정보를 저장
exports.addUser = async (student_id, email, password, name, major, grade, gender, residence) => {
    const [result] = await db.query(
        'INSERT INTO users (student_id, email, password, name, major, grade, gender, residence) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [student_id, email, password, name, major, grade, gender, residence]
    );
    return result;
}

// 사용자 정보 수정
exports.updateUserInfo = async (student_id, name, major, grade, residence) => {
    const result = await db.query(
        'UPDATE users SET name = ?, major = ?, grade = ?, residence = ? WHERE student_id = ?',
        [name, major, grade, residence, student_id]
    );
    return result;
}

// 사용자 비밀번호 수정
exports.updateUserPassword = async (student_id, newPassword) => {
    const result = await db.query(
        'UPDATE users SET password = ? WHERE student_id = ?',
        [newPassword, student_id]
    );
    return result;
}

// 사용자 삭제
exports.deleteUser = async (student_id) => {
    const result = await db.query(
        'DELETE FROM users WHERE student_id = ?', [student_id]
    )
}

// DB에 입력된 Refresh Token이 있는지 확인
exports.findUserByToken = async (refreshToken) => {
    const [users] = await db.query('SELECT * FROM users where refresh_token = ?', [refreshToken]);
    return users[0];
}