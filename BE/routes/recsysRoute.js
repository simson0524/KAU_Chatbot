const express = require('express');
const router = express.Router();
const RecSysController = require('../controller/recsysController');

// RAG에서 받은 공지 데이터를 RecSys로 전송
router.post('/recsys', RecSysController.handleRecSysRequest);

// 추천 데이터 저장 (RecSys에서 전달)
router.post('/recommendations', RecSysController.handleSaveRecommendations);

// 특정 유저의 추천 데이터 조회
router.get('/recommendations/:student_id', RecSysController.handleGetUserRecommendations);


module.exports = router;
