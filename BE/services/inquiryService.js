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

exports.addComment = async (inquiry_id, content, student_id) => {
  // 관리자 인증
  const isAdmin = await exports.isAdmin(student_id);
  if (!isAdmin) {
    throw new Error('권한 없음: 관리자만 댓글을 작성할 수 있습니다.');
  }

  // 학번에 따른 department_id 매핑
  const departmentMapping = {
    '11111111': 1,
    '22222222': 2,
    '33333333': 3,
    '44444444': 4,
    '55555555': 5,
    '66666666': 6,
    '77777777': 7,
    '88888888': 8,
  };
  const department_id = departmentMapping[student_id];

  if (!department_id) {
    throw new Error('유효하지 않은 학번입니다.');
  }

  // 댓글 삽입
  return await InquiryModel.addComment(inquiry_id, department_id, content);
};


// 관리자 인증 함수
exports.isAdmin = async (student_id) => {
  // 관리자 학번 목록
  const adminIds = [
    '11111111', '22222222', '33333333', 
    '44444444', '55555555', '66666666', 
    '77777777', '88888888'
  ];

  // 학번이 관리자 목록에 포함되어 있는지 확인
  return adminIds.includes(String(student_id));
};

