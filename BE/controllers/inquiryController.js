const Inquiry = require('../models/inquiryModel');
const InquiryService = require('../services/inquiryService');

exports.getAllInquiries = async (req, res) => {
    try {
      const inquiries = await InquiryService.getAllInquiries();
      res.json(inquiries);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  exports.getInquiryDetails = async (req, res) => {
    const { id } = req.params;
    try {
      const details = await InquiryService.getInquiryDetails(id);
      res.json(details);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  exports.createInquiry = async (req, res) => {
    const { title, content, department_id } = req.body;
    const student_id = req.user.student_id; 
    try {
      const inquiryId = await InquiryService.createInquiry(student_id, title, content, department_id);
      res.status(201).json({ inquiryId });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };




