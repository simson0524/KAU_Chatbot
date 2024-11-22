const dataService = require('../services/dataService');
const fs = require('fs');
const csv = require('csv-parser');

exports.uploadData = async (req, res) => {
    try {
        const filePath = req.file.path;
        const rows = [];

        // CSV 파일 파싱
        fs.createReadStream(filePath)
        .pipe(csv({ headers: ['idx', 'text', 'files', 'url', 'title', 'published_date', 'deadline_date'] }))
        .on('data', (data) => rows.push(data))
        .on('end', async () => {
            await dataService.saveData(rows);
            fs.unlinkSync(filePath); // 임시 파일 삭제
            res.status(200).json({ message: '데이터 업로드 성공' });
        });
    } catch (error) {
        console.error('데이터 업로드 실패:', error);
        res.status(500).json({ error: '데이터 업로드 실패' });
    }
};
