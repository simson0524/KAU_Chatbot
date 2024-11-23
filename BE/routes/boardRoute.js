const express = require('express');
const router = express.Router();
const boardController = require('../controllers/boardController');
const boardService = require('../services/boardService');
const userService = require('../services/userService');

// 학과 게시판 조회
router.get('/major/:major_identifier', userService.loginRequired, boardController.getMajorBoard);

// 학과 게시판 생성
router.post('/major/:major_identifier', userService.loginRequired, boardController.createMajorBoard);

// 학과 게시판 상세 조회
router.get('/major/:major_identifier/:board_id', userService.loginRequired, boardController.getDetailMajorBoard);

// 학과 게시판 댓글 생성
router.post('/major/:major_identifier/:board_id/comments', userService.loginRequired, boardController.createMajorComments);

// 학과 게시판 삭제
router.delete('/major/:major_identifier/:board_id', userService.loginRequired, boardController.deleteBoard);

// 학과 게시판 수정 페이지
router.get('/major/:major_identifier/:board_id/update', userService.loginRequired, boardController.getMajorBoardUpdate);

// 학과 게시판 수정
router.put('/major/:major_identifier/:board_id/update', userService.loginRequired, boardController.updateBoard);

// 학번 게시판 조회
router.get('/studentId/:student_identifier', userService.loginRequired, boardController.getStudentBoard);

// 학번 게시판 생성
router.post('/studentId/:student_identifier', userService.loginRequired, boardController.createStudentIdBoard);

// 학번 게시판 상세 조회
router.get('/studentId/:student_identifier/:board_id', userService.loginRequired, boardController.getDetailStudentBoard);

// 학번 게시판 댓글 생성
router.post('/studentId/:student_identifier/:board_id/comments', userService.loginRequired, boardController.createStudentComments);

// 학번 게시판 삭제
router.delete('/studentId/:student_identifier/:board_id', userService.loginRequired, boardController.deleteBoard);

// 학과 게시판 수정 페이지
router.get('/studentId/:student_identifier/:board_id/update', userService.loginRequired, boardController.getStudentBoardUpdate);

// 학번 게시판 수정
router.put('/studentId/:student_identifier/:board_id/update', userService.loginRequired, boardController.updateBoard);


module.exports = router;