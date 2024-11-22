const InquiryModel = require('../models/inquiryModel');

// 모든 문의 가져오기
exports.getAllInquiries = async (student_id) => {
  return await InquiryModel.getAllInquiries();
};

// 특정 문의와 상세 정보 가져오기
exports.getInquiryDetails = async (inquiry_id, student_id) => {
  const inquiry = await InquiryModel.getInquiryById(inquiry_id);
  if (!inquiry) throw new Error('Inquiry not found');
  return inquiry;
};

// 새로운 문의 생성
exports.createInquiry = async (student_id, title, content, department_id) => {
  return await InquiryModel.createInquiry(student_id, title, content, department_id);
};

// 모든 부서 가져오기
exports.getAllDepartments = async () => {
  return await InquiryModel.getAllDepartments();
};

// 문의 삭제
exports.deleteInquiry = async (inquiry_id, student_id) => {
  const inquiry = await InquiryModel.getInquiryById(inquiry_id, student_id);
  if (!inquiry) return false; // 문의가 없거나 권한이 없는 경우
  return await InquiryModel.deleteInquiryById(inquiry_id, student_id);
};
