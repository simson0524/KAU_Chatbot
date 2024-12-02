const admin = require('firebase-admin');
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
        const response = await axios.post('http://3.38.42.182:80/csv', {
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

// 알림 메시지 전송
exports.sendNotifications = async (tokens) => {
    if (tokens.length === 0) {
      console.log('No tokens to send notifications.');
      return;
    }
  
    const message = {
      notification: {
        title: '관심 공지 알림',
        body: '회원님이 관심있어 할만한 공지가 업로드 되었습니다! 확인해보세요!',
      },
      tokens,
    };
  
    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`Successfully sent: ${response.successCount} messages.`);
      console.log(`Failed to send: ${response.failureCount} messages.`);
    } catch (error) {
      console.error('Error sending notifications:', error);
    }
  };

// 관심 있는 사용자에게 알림 전송
exports.notifyInterestedUsers = async () => {
    try {
      const tokens = await recsysModel.getUsersWithInterestNotices();
      await exports.sendNotifications(tokens);
    } catch (error) {
      console.error('Error in notifyInterestedUsers:', error);
    }
  };    

  // npm install express mysql2 firebase-admin node-cron
  // serviceAccountKey.json 파일을 Firebase Console에서 다운로드하여 프로젝트에 추가.