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


// 학교 공지 목록 조회 API
exports.getSchoolNotices = async (req, res) => {
    try {
        const notices = await dataService.getSchoolNotices();
        res.status(200).json({
            message: '학교 공지 목록 조회 성공',
            notices
        });
    } catch (error) {
        console.error('학교 공지 목록 조회 중 오류:', error);
        res.status(500).json({ error: '학교 공지 목록 조회 실패' });
    }
};

// 학교 공지 상세 조회 API
exports.getSchoolNoticeDetail = async (req, res) => {
    try {
        const idx = req.params.idx;
        const notice = await dataService.getSchoolNoticeDetail(idx);
        if (!notice) {
            return res.status(404).json({ error: '해당 공지를 찾을 수 없습니다.' });
        }
        res.status(200).json({
            message: '학교 공지 상세 조회 성공',
            notice
        });
    } catch (error) {
        console.error('학교 공지 상세 조회 중 오류:', error);
        res.status(500).json({ error: '학교 공지 상세 조회 실패' });
    }
};
