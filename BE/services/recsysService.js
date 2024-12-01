const axios = require('axios');
const recsysModel = require('../models/recsysModel');

exports.fetchAllStudentData = async () => {
    const students = await recsysModel.getAllUsersWithTags();
    const formattedData = students.map(student => ({
        student_id: student.student_id,
        tags: student.tags ? student.tags.split(',').slice(0, 50) : []
    }));

    // recsys 서버로 데이터 전송
    try {
        const response = await axios.post('https://recsys-server-url.com/api/students', {
            student_id_cnt: formattedData.length,
            data: formattedData
        });
        console.log('Data successfully sent to recsys server:', response.data);
    } catch (error) {
        console.error('Failed to send data to recsys server:', error.message);
    }

    return formattedData; // 클라이언트에도 반환
};

exports.processAndSaveStudentData = async (studentData) => {
    // 1. 기존 데이터 삭제
    await recsysModel.clearInterestNoticeTitles();

    // 2. 새로운 데이터 저장
    const students = studentData.data.map(student => ({
        student_id: student.student_id,
        interest_notice_titles: student.interest_notice_titles.slice(0, 50) // 최대 50개의 공지사항 제한
    }));

    await recsysModel.saveInterestNoticeTitles(students);
};