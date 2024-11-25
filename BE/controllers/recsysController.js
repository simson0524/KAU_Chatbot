const recsysService = require('./recsysService');

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