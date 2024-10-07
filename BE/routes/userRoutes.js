// userRoutes.js
// 사용자 관련 API 요청을 처리하는 라우터

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.post('/login', userController.userLogin);

router.post('/register', userController.userSignUp);

router.post('/send-email', userController.sendEmail);

router.post('/verify-email', userController.verifyCode);

module.exports = router;