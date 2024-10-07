// userService.js
// 사용자 관련 비즈니스 로직을 처리하는 서비스 계층
const nodemailer = require('nodemailer');

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
        html: `<h3>산학 프로젝트 7조 - 이메일 인증 테스트<h3></p></p>
                <h2>${authNumber}<h2>`
    }
}

// 인증번호 생성
exports.generateCode = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
}
