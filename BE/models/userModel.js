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
    const [users] = await db.query('SELECT student_id, email, name, major, grade, gender, residence FROM users where student_id = ?', [student_id]);
    return users[0];
}

// refresh Token을 DB에 저장
exports.saveRefToken = async (student_id, refreshToken) => {
    const [result] = await db.query(
        'UPDATE users SET refresh_token = ? WHERE student_id = ?',
        [refreshToken, student_id]
    );
    return result;
}

// DB에 입력한 사용자 정보를 저장
exports.addUser = async (student_id, email, password, name, major, grade, gender, residence) => {
    const [result] = await db.query(
        'INSERT INTO users (student_id, email, password, name, major, grade, gender, residence) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [student_id, email, password, name, major, grade, gender, residence]
    );
    return result;
}

// 사용자 채팅 캐릭터 설정
exports.updateUserCharacter = async (email, chat_character) => {
    const result = await db.query(
        'UPDATE users SET chat_character = ? WHERE email = ?',
        [chat_character, email]
    )

    return result;
}

// 사용자 정보 수정
exports.updateUserInfo = async (student_id, name, major, grade, residence, chat_character) => {
    const result = await db.query(
        'UPDATE users SET name = ?, major = ?, grade = ?, residence = ?, chat_character = ? WHERE student_id = ?',
        [name, major, grade, residence, chat_character, student_id]
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

// 사용자 삭제
exports.deleteUser = async (student_id) => {
    const result = await db.query(
        'DELETE FROM users WHERE student_id = ?', [student_id]
    )
    return result;
}

// 사용자 관련된 데이터 삭제
exports.deleteUserRelatedData = async (student_id) => {
    const deleteChat = await db.query(
        'DELETE FROM chat WHERE student_id = ?', [student_id]
    );
    
    const deleteChatRoom = await db.query(
        'DELETE FROM chat_room WHERE student_id = ?', [student_id]
    );
    
    const deleteInquiryBoard = await db.query(
        'DELETE FROM inquiry_board WHERE student_id = ?', [student_id]
    );
    
    const deleteTagSequence = await db.query(
        'DELETE FROM tag_sequence WHERE student_id = ?', [student_id]
    );
    
    const deleteBoard = await db.query(
        'DELETE FROM boards WHERE author = ?', [student_id]
    );

    return {deleteChat, deleteChatRoom, deleteInquiryBoard, deleteTagSequence};
}

// 사용자 관련된 태그 데이터 삭제
exports.deleteChatDataByUser = async (student_id) => {
    const result = await db.query(
        'DELETE FROM tag_sequence WHERE student_id = ?', [student_id]
    )
    return result;
}

// DB에 입력된 Refresh Token이 있는지 확인
exports.findUserByToken = async (refreshToken) => {
    const [users] = await db.query('SELECT * FROM users where refresh_token = ?', [refreshToken]);
    return users[0];
}

// 사용자의 FCM 토큰 가져오기
exports.getUserFcmToken = async (student_id) => {
    const [fcm_token] = await db.query('SELECT fcm_token FROM users where student_id = ?', [student_id]);
    return fcm_token[0];
}

// fcm 토큰 저장하기
exports.saveFcmToken = async (email, fcmToken) => {
    const result = await db.query(
        'UPDATE users SET fcm_token = ? WHERE email = ?',
        [fcmToken, email]
    );
    return result;
}