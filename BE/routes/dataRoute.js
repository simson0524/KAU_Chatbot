const express = require('express');
const router = express.Router();
const dataController = require('../controllers/dataController');
const userService = require('../services/userService');

const multer = require('multer');
const upload = multer({
    dest: 'uploads/',
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB로 파일 크기 제한 설정
});

router.post('/upload', upload.single('file'), dataController.uploadData);

// 학교 공지 목록 조회
router.get('/school',  dataController.getSchoolNotices);

// 학교 공지 상세 조회
router.get('/school/:idx', dataController.getSchoolNoticeDetail);

// 외부 공지 목록 조회
router.get('/external', dataController.getExternalNotices);

// 외부 공지 상세 조회
router.get('/external/:idx', dataController.getExternalNoticeDetail);

module.exports = router;
