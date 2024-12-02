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

// 관심 있는 사용자에게 알림 트리거
exports.triggerNotifications = async (req, res) => {
    try {
      await recsysService.notifyInterestedUsers();
      res.status(200).json({ message: 'Notifications triggered successfully.' });
    } catch (error) {
      console.error('Error in triggerNotifications:', error);
      res.status(500).json({ error: 'Failed to trigger notifications.' });
    }
  };