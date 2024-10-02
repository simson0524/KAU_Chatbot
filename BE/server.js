const http = require('http');
const app = require('./app'); // app.js에서 설정한 Express 앱을 가져옴
const db = require('./config/dbConfig'); // DB 연결 설정 가져오기

const port = process.env.PORT || 3000; // 포트 번호 설정 (기본값: 3000)

const server = http.createServer(app); // HTTP 서버 생성

// 서버 시작 함수
const startServer = async () => {
    try {
        // DB 연결 테스트
        await db.query('SELECT 1');
        console.log('Database connected successfully');

        // 서버 시작
        server.listen(port, () => {
            console.log(`Server is running on port ${port}`);
        });
    } catch (error) {
        console.error('Error starting the server:', error);
        process.exit(1); // 에러 발생 시 서버 종료
    }
};

// 서버 시작 함수 호출
startServer();
