// userRoutes.js
// 사용자 관련 API 요청을 처리하는 라우터

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const userService = require('../services/userService');

router.post('/login', userController.userLogin);

router.post('/register', userController.userSignUp);

router.put('/:student_id', userService.loginRequired, userController.updateUser);

router.put('/:student_id/password', userService.loginRequired, userController.updatePassword);

router.delete('/:student_id', userService.loginRequired, userController.deleteUser);

router.post('/send-email', userController.sendEmail);

router.post('/verify-email', userController.verifyCode);

router.post('/token', userController.getToken);

module.exports = router;