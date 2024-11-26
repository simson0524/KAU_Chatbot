const dataService = require('../services/dataService');
const fs = require('fs');
const csv = require('csv-parser');
const moment = require('moment');

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

// 외부 공지 목록 조회 API
exports.getExternalNotices = async (req, res) => {
    try {
        const notices = await dataService.getExternalNotices();
        const today = moment(); // 현재 날짜

        // D-Day 계산 추가
        const formattedNotices = notices.map((notice) => {
            const deadline = moment(notice.deadline_date);
            const dDay = deadline.diff(today, 'days'); // 현재 날짜와 마감일의 차이 계산

            return {
                ...notice,
                dDay: dDay >= 0 ? `D-${dDay}` : `D+${Math.abs(dDay)}` // D-Day 형식으로 추가
            };
        });

        res.status(200).json({
            message: '외부 공지 목록 조회 성공',
            notices: formattedNotices
        });
    } catch (error) {
        console.error('외부 공지 목록 조회 중 오류:', error);
        res.status(500).json({ error: '외부 공지 목록 조회 실패' });
    }
};

// 외부 공지 상세 조회 API
exports.getExternalNoticeDetail = async (req, res) => {
    try {
        const idx = req.params.idx;
        const notice = await dataService.getExternalNoticeDetail(idx);

        if (!notice) {
            return res.status(404).json({ error: '해당 공지를 찾을 수 없습니다.' });
        }

        const today = moment(); // 현재 날짜
        const deadline = moment(notice.deadline_date);
        const dDay = deadline.diff(today, 'days'); // D-Day 계산

        // `dDay` 추가한 데이터 반환
        res.status(200).json({
            message: '외부 공지 상세 조회 성공',
            notice: {
                ...notice,
                dDay: dDay >= 0 ? `D-${dDay}` : `D+${Math.abs(dDay)}`,
            },
        });
    } catch (error) {
        console.error('외부 공지 상세 조회 중 오류:', error);
        res.status(500).json({ error: '외부 공지 상세 조회 실패' });
    }
};