// userRoutes.js
// 사용자 관련 API 요청을 처리하는 라우터

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const userService = require('../services/userService');

// 로그인
router.post('/login', userController.userLogin);

// 회원가입
router.post('/register', userController.userSignUp);

// 사용자의 채팅 캐릭터 설정
router.post('/character', userController.setCharacter);

// 사용자 정보 가져오기
router.get('/', userService.loginRequired, userController.getUserData);

// 사용자 정보 수정
router.put('/', userService.loginRequired, userController.updateUser);

// 사용자 비밀번호 수정
router.put('/password', userService.loginRequired, userController.updatePassword);

// 사용자 비밀번호 찾기 -> 새 비밀번호를 생성해서 전달해줌
router.get('/password', userController.getNewPassword);

// 사용자 탈퇴
router.delete('/', userService.loginRequired, userController.deleteUser);

// 이메일로 인증번호 전송
router.post('/send-email', userController.sendEmail);

// 이메일 일치 확인
router.post('/verify-email', userController.verifyCode);

// Access Token 재발급
router.post('/token', userController.getToken);

module.exports = router;