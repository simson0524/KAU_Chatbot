const recsysService = require('../services/recsysService');

exports.getAllStudentData = async (req, res) => {
    try {
        const studentData = await recsysService.fetchAllStudentData();
        const response = {
            student_id_cnt: studentData.length,
            data: studentData
        };
        res.status(200).json(response);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.updateInterestNoticeTitles = async (req, res) => {
    try {
        const studentData = req.body;

        // 데이터 유효성 검사
        if (!studentData || !studentData.data || !Array.isArray(studentData.data)) {
            return res.status(400).json({ message: 'Invalid data format.' });
        }

        // 데이터 처리 및 저장
        await recsysService.processAndSaveStudentData(studentData);

        res.status(200).json({ message: 'Interest notice titles successfully updated.' });
    } catch (error) {
        console.error('Error updating interest notice titles:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};


// 즉시 알림 전송 API
exports.sendNotifications = async (req, res) => {
    try {
        const results = await recsysService.sendDailyNotifications();
        res.status(200).json({
            message: "Notifications sent successfully!",
            results
        });
    } catch (error) {
        console.error("Error sending notifications:", error);
        res.status(500).json({
            message: "Failed to send notifications",
            error: error.message
        });
    }
};