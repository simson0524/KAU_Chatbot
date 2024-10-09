const mysql = require('mysql2/promise');

// MySQL 연결 설정
const pool = mysql.createPool({
    host: 'kauchat.cjickk6s657t.ap-northeast-2.rds.amazonaws.com', // DB 호스트
    user: 'admin', // DB 사용자명
    password: 'kaurag7&', // DB 비밀번호
    database: 'KAUChatDB', // DB 이름
    port: 3306, // 포트번호
    waitForConnections: true, // 연결 대기 설정
    connectionLimit: 10, // 최대 연결 수
    queueLimit: 0 // 큐 제한
});

module.exports = pool; // pool 모듈로 내보내기
