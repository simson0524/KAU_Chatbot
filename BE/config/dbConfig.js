const mysql = require('mysql2/promise');

// MySQL 연결 설정
const pool = mysql.createPool({
    host: process.env.DB_HOST, // DB 호스트
    user: process.env.DB_USER, // DB 사용자명
    password: process.env.DB_PASSWORD, // DB 비밀번호
    database: process.env.DB_NAME, // DB 이름
    waitForConnections: true, // 연결 대기 설정
    connectionLimit: 10, // 최대 연결 수
    queueLimit: 0 // 큐 제한
});

module.exports = pool; // pool 모듈로 내보내기
