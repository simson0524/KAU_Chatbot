const admin = require('firebase-admin');
const axios = require('axios');
const recsysModel = require('../models/recsysModel');

exports.fetchAllStudentData = async () => {
    const students = await recsysModel.getAllUsersWithTags();
    const formattedData = students.map(student => ({
        student_id: student.student_id,
        major: student.major, // major 추가
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

  // npm install express mysql2 firebase-admin node-cron
  // serviceAccountKey.json 파일을 Firebase Console에서 다운로드하여 프로젝트에 추가.


// FCM 알림 전송 함수
const sendNotification = async (fcmToken, interests) => {
    const message = {
        notification: {
            title: "KAU CHATBOT",
            body: "회원님이 관심있어 할만한 공지가 업로드 되었습니다! 확인해보세요!"
        },
        data: {
            interests: JSON.stringify(interests) // 공지 제목을 JSON 문자열로 변환
        },
        token: fcmToken
    };

    try {
        await admin.messaging().send(message); // FCM 메시지 전송
        console.log(`Notification sent to token: ${fcmToken}`);
    } catch (error) {
        console.error(`Failed to send notification to ${fcmToken}: ${error.message}`);
        if (error.code === 'messaging/registration-token-not-registered') {
            console.log(`Removing invalid token: ${fcmToken}`);
        }
    }
};

// 모든 사용자에게 알림 전송
exports.sendDailyNotifications = async () => {
    const users = await recsysModel.getUsersWithInterests();
    const results = []; // 전송 결과 저장

    for (const user of users) {
        const fcmToken = await recsysModel.getFcmToken(user.student_id);
        if (fcmToken) {
            try {
                await sendNotification(fcmToken, user.interests);
                results.push({
                    student_id: user.student_id,
                    status: "success",
                    interests: user.interests
                });
            } catch (error) {
                console.error(`Failed to send notification to ${user.student_id}:`, error.message);
                results.push({
                    student_id: user.student_id,
                    status: "failure",
                    error: error.message
                });
            }
        } else {
            console.warn(`No FCM token found for student_id=${user.student_id}`);
            results.push({
                student_id: user.student_id,
                status: "no_token"
            });
        }
    }

    return results; // 결과 반환
};

