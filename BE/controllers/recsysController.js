const RecSysService = require('../service/recsysService');

exports.handleRecSysRequest = async (req, res) => {
    try {
        const { notifications } = req.body;

        if (!notifications || notifications.length === 0) {
            return res.status(400).json({ message: 'No notifications provided' });
        }

        const result = await RecSysService.processAndSendToRecSys(notifications);

        return res.status(200).json({ message: 'Data sent to RecSys successfully', result });
    } catch (error) {
        console.error('Error in handleRecSysRequest:', error);
        return res.status(500).json({ message: 'Internal Server Error' });
    }
};


exports.handleSaveRecommendations = async (req, res) => {
    try {
        const { recommendations } = req.body;

        if (!recommendations || recommendations.length === 0) {
            return res.status(400).json({ message: 'No recommendations provided' });
        }

        const result = await RecSysService.saveRecommendations(recommendations);

        return res.status(200).json(result);
    } catch (error) {
        console.error('Error in handleSaveRecommendations:', error);
        return res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.handleGetUserRecommendations = async (req, res) => {
    try {
        const { student_id } = req.params;

        if (!student_id) {
            return res.status(400).json({ message: 'Missing student_id' });
        }

        const recommendations = await RecSysService.getUserRecommendations(student_id);

        return res.status(200).json({ student_id, recommendations });
    } catch (error) {
        console.error('Error in handleGetUserRecommendations:', error);
        return res.status(500).json({ message: 'Internal Server Error' });
    }
};