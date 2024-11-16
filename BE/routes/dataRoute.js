const express = require('express');
const router = express.Router();
const dataController = require('../controllers/dataController');

const multer = require('multer');
const upload = multer({
    dest: 'uploads/',
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB로 파일 크기 제한 설정
});

router.post('/upload', upload.single('file'), dataController.uploadData);

module.exports = router;