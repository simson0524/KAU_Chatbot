const RecSysModel = require('../model/recsysModel');
const axios = require('axios');

exports.processAndSendToRecSys = async (notifications) => {
    try {
        // RAG에서 받은 공지 키워드 정보
        const processedNotifications = notifications.map(notification => ({
            title: notification.title,
            keywords: notification.keywords
        }));

        // tag_sequence 테이블의 모든 데이터 가져오기
        const userTags = await RecSysModel.getAllUserTags();

        // RecSys로 보낼 데이터 구성
        const recSysPayload = {
            notifications: processedNotifications,
            users: userTags // 모든 유저 데이터 포함
        };

        // RecSys API 호출
        const recSysUrl = 'http://recsys-instance/api/recommend'; // RecSys 인스턴스 엔드포인트
        const response = await axios.post(recSysUrl, recSysPayload);

        console.log('RecSys Response:', response.data);
        return response.data;
    } catch (error) {
        console.error('Error in processAndSendToRecSys:', error);
        throw error;
    }
};

const RecSysModel = require('../model/recsysModel');

exports.processRecSysResponse = async (recommendationData) => {
    try {
        // RecSys에서 받은 데이터를 검증
        if (!recommendationData || !Array.isArray(recommendationData)) {
            throw new Error('Invalid recommendation data format');
        }

        // 데이터 저장
        const recommendations = recommendationData.map(rec => ({
            student_id: rec.student_id,
            notification_ids: rec.notification_ids // 공지 ID 리스트
        }));

        await RecSysModel.updateUserRecommendations(recommendations);

        return { message: 'Recommendations successfully updated in tag_sequence.' };
    } catch (error) {
        console.error('Error in processRecSysResponse:', error);
        throw error;
    }
};

exports.saveRecommendations = async (recommendations) => {
    try {
        for (const { student_id, notification_ids } of recommendations) {
            // 각 유저의 추천 데이터를 업데이트
            await RecSyseModel.updateRecommendations(student_id, notification_ids);
        }
        return { message: 'Recommendations updated successfully.' };
    } catch (error) {
        console.error('Error in saveRecommendations:', error);
        throw error;
    }
};

exports.getUserRecommendations = async (student_id) => {
    try {
        // 특정 유저의 추천 데이터를 조회
        const recommendations = await RecSysModel.getRecommendations(student_id);
        return recommendations;
    } catch (error) {
        console.error('Error in getUserRecommendations:', error);
        throw error;
    }
};