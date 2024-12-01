const express = require('express');
const RecsysController = require('../controllers/recsysController');
const router = express.Router();

router.get('/students', RecsysController.getAllStudentData);

router.post('/update-notices', RecsysController.updateInterestNoticeTitles);

module.exports = router;