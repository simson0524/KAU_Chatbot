const express = require('express');
const router = express.Router();
const inquiryController = require('../controllers/inquiryController');
const userService = require('../services/userService');

// 모든 부서 조회 라우터
router.get('/departments', inquiryController.getAllDepartments);

// 모든 문의 조회 라우터
router.get('/', userService.loginRequired, inquiryController.getAllInquiries);

// 특정 문의 조회 라우터
router.get('/:id', userService.loginRequired, inquiryController.getInquiryDetails);

// 문의 생성 라우터
router.post('/', userService.loginRequired, inquiryController.createInquiry);

// 문의 삭제 라우터
router.delete('/:id', userService.loginRequired, inquiryController.deleteInquiry);

// 댓글 작성 API
router.post('/:id/comments', userService.loginRequired, inquiryController.addComment);


module.exports = router;