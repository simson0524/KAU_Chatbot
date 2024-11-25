const express = require('express');
const RecsysController = require('./recsysController');
const router = express.Router();

router.get('/students', RecsysController.getAllStudentData);

module.exports = router;