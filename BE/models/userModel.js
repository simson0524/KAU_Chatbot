// userModel.js
// 사용자 정보를 저장하고 관리하는 DB 모델

const db = require('../config/dbConfig');

// DB에 입력된 이메일의 사용자가 있는지 확인
exports.findUserByEmail = async (email) => {
    const [users] = await db.query('SELECT * FROM users where email = ?', [email]);
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
exports.updateUserInfo = async (email, name, major, grade, residence) => {
    const result = await db.query(
        'UPDATE users SET name = ?, major = ?, grade = ?, residence = ? WHERE email = ?',
        [name, major, grade, residence, email]
    );
    return result;
}

// 사용자 비밀번호 수정
exports.updateUserPassword = async (email, newPassword) => {
    const result = await db.query(
        'UPDATE users SET password = ? WHERE email = ?',
        [newPassword, email]
    );
    return result;
}