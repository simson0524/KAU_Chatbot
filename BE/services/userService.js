// userService.js
// 사용자 관련 비즈니스 로직을 처리하는 서비스 계층
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');

// transporter 설정
exports.transporter = nodemailer.createTransport({
    host: 'smtp-mail.outlook.com',
    port: 587,
    secure: false,
    auth: {
        user: 'jewoo2000@kau.kr',
        pass: 'jh^^0909'
    }
})

// 이메일 보내는 옵션 세팅
exports.getMailOptions = (to, authNumber) => {
    return {
        from: 'jewoo2000@kau.kr',
        to: to, // 도착 메일 주소
        subject: '이메일 인증',
        html: `<h3>KAU RAG - 이메일 인증<h3></p></p>
                <h2>${authNumber}<h2>`
    }
}

// 인증번호 생성
exports.generateCode = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// 임시 비밀번호 생성
exports.generateTempPassword = () => {
    return Math.random().toString(36).slice(2);
}

// 로그인 되었는지 확인하는 미들웨어
exports.loginRequired = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // 'Bearer TOKEN'에서 TOKEN만 추출

    if (!token) {
      return res.status(401).json({ message: 'Access Token이 필요합니다.' });
    }
    
    // 토큰 검증
    jwt.verify(token, 'access-secretKey', (err, user) => {
        if (err) {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        req.user = user; // 유저 정보를 req 객체에 추가 -> 이러면 이후 미들웨어는 req.user로 사용자 정보에 접근할 수 있음
        next(); // 다음 미들웨어로 이동
    });
}
