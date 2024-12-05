const Inquiry = require('../models/inquiryModel');
const InquiryService = require('../services/inquiryService');
const userService = require('../services/userService'); 
const boardService = require('../services/boardService');


exports.getAllInquiries = async (req, res) => {

  const studentId = req.user.student_id; 

    try {
      const inquiries = await InquiryService.getAllInquiries(studentId);
      res.json(inquiries);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  exports.getInquiryDetails = async (req, res) => {
    const { id } = req.params;
    const studentId = req.user.student_id; 
    try {
      const details = await InquiryService.getInquiryDetails(id, studentId);
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

exports.getAllDepartments = async (req, res) => {
  try {
    const departments = await InquiryService.getAllDepartments();
    res.status(200).json({
      success: true,
      data: departments,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

exports.deleteInquiry = async (req, res) => {
  const { id } = req.params; 
  const student_id = req.user.student_id; 

  try {
    const result = await InquiryService.deleteInquiry(id, student_id);
    if (result) {
      res.status(200).json({ message: 'Inquiry deleted successfully' });
    } else {
      res.status(404).json({ error: 'Inquiry not found or not authorized' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 댓글 작성 컨트롤러
exports.addComment = async (req, res) => {
  const { id: inquiry_id } = req.params; // 문의 ID
  const { content } = req.body; // 댓글 내용
  const student_id = req.user.student_id; 

  // student_id 값 확인용 로그
  console.log('현재 접속 중인 학번:', student_id);

  try {
    const commentId = await InquiryService.addComment(
      inquiry_id,
      content,
      student_id
    );

    // 작성자에게 푸시 알림 보내기
    const inquiry = await InquiryService.getInquiryDetails(inquiry_id, student_id);
    await boardService.pushMessage(inquiry.student_id, content)

    res.status(201).json({ success: true, commentId });
  } catch (err) {
    res.status(403).json({ success: false, message: err.message });
  }
};


