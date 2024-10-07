const express = require('express');
const bodyParser = require('body-parser');
const chatRoutes = require('./routes/chatRoute'); // 챗봇 관련 라우트 가져오기
const userRoutes = require('./routes/userRoutes'); // 사용자 관련 라우트 가져오기
const errorMiddleware = require('./middlewares/errorMiddleware'); // 에러 처리 미들웨어


const app = express(); // Express 애플리케이션 생성

// 미들웨어 설정
app.use(bodyParser.json()); // JSON 요청 본문 파싱
app.use(bodyParser.urlencoded({ extended: true })); // URL 인코딩된 데이터 파싱

// 라우트 설정
app.use('/api', chatRoutes); // '/api' 경로에 챗봇 관련 라우트 적용
app.use('/user', userRoutes); // '/auth' 경로에 사용자 관련 라우트 적용

module.exports = app; // Express 앱을 모듈로 내보냄
