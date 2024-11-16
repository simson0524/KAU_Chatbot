const express = require('express');
const router = express.Router();
const inquiryController = require('../controllers/inquiryController');
const userService = require('../services/userService');

router.get('/', inquiryController.getAllInquiries);

router.get('/:id', inquiryController.getInquiryDetails);

router.post('/', userService.loginRequired, inquiryController.createInquiry);

module.exports = router;