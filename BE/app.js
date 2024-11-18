const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const chatRoutes = require('./routes/chatRoute'); // 챗봇 관련 라우트 가져오기
const userRoutes = require('./routes/userRoutes'); // 사용자 관련 라우트 가져오기
const inquiryRoutes = require('./routes/inquiryRoute'); // 문의 게시판 라우트 추가 
const boardRoutes = require('./routes/boardRoute');
const dataRoutes = require('./routes/dataRoute'); // csv데이터 관련 라우트 가져오기
// const errorMiddleware = require('./middlewares/errorMiddleware'); // 에러 처리 미들웨어

const app = express(); // Express 애플리케이션 생성

// CORS 설정 - 모든 출처 허용
app.use(cors());  // CORS 설정이 라우트보다 위에 있어야 함

// 미들웨어 설정
app.use(bodyParser.json()); // JSON 요청 본문 파싱
app.use(bodyParser.urlencoded({ extended: true })); // URL 인코딩된 데이터 파싱
app.use(express.json());

// 라우트 설정
app.use('/chat', chatRoutes); // '/chat' 경로에 챗봇 관련 라우트 적용
app.use('/user', userRoutes); // '/user' 경로에 사용자 관련 라우트 적용
app.use('/board/inquiries', inquiryRoutes); // 문의 게시판 라우트
app.use('/board', boardRoutes); // 학과, 학번 게시판 라우트
app.use('/data', dataRoutes); // '/upload' 경로에 csv데이터 관련 라우트 적용

module.exports = app; // Express 앱을 모듈로 내보냄
