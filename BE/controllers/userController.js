const userService = require('../services/userService');
const userModel = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.userLogin = async (req, res) => {

    try {
        const { email, password } = req.body;

        // 이메일로 사용자 찾기
        const user = await userModel.findUserByEmail(email); // db에 입력한 정보의 사용자가 있는지 검색하기
        if (!user) {
            return res.status(400).json({error: '이메일을 잘못 입력하셨습니다'});
        }

        // 비밀번호 확인
        const isPasswordValid = await bcrypt.compare(password, user.password); // 입력한 비밀번호와 암호화되어 저장된 비밀번호가 맞는지 확인
        if (!isPasswordValid) {
            return res.status(400).json({error: '비밀번호를 잘못 입력하셨습니다'});
        }
        // JWT 토큰 생성 -> secret-key는 .env에 저장 필요
        const accessToken = jwt.sign({email: user.email}, 'access-secretKey', {expiresIn: '1h'});
        const refreshToken = jwt.sign({email: user.email}, 'refresh-secretKey', {expiresIn: '1d'});

        userModel.saveRefToken(user.email, refreshToken); // Refresh Token은 DB에 저장

        res.status(200).json({accessToken, refreshToken, "message": "로그인이 성공하였습니다."});

    } catch (error) {
        console.error(error);
    }
}

exports.userSignUp = async (req, res) => {
    const { student_id, email, password, name, major, grade, gender, residence } = req.body;

    try {
        const emailExists = await userModel.findUserByEmail(email); // 이미 동일한 이메일이 있는지 확인
        if (emailExists) {
            return res.status(400).json({error: '이미 존재하는 이메일입니다.'});
        }
        
        // 비밀번호 해싱
        const hashedPassword = await bcrypt.hash(password, 10);

        await userModel.addUser(student_id, email, hashedPassword, name, major, grade, gender, residence); // DB에 사용자 정보 저장 -> 비밀번호 저장 시 암호화 필요
        res.status(201).json({'message': '회원가입이 성공하였습니다.'});
    }
    catch (error) {
        console.error(error);
    }
}

// 입력한 이메일에 인증번호 보내기
exports.sendEmail = async (req, res) => {
    const email = req.body.email;

    try {
        const verificationNumber = userService.generateCode();
        const mailOptions = userService.getMailOptions(email, verificationNumber);
        await userService.transporter.sendMail(mailOptions)
        .then(() => {
            return res.status(200).json('이메일 보내기 성공');
        })
        .catch((error) => {
            return res.status(500).json('이메일 보내기 실패');
        })
    }
    catch (error) {
        console.error(error);
    }
}

// 이메일에 전송한 인증번호와 사용자가 입력한 인증번호가 같은지 확인
exports.verifyCode = async (req, res) => {
    const email = req.body.email;
    const code = req.body.code;

    if (code == '전송된 인증번호') { // 전송된 인증번호는 DB나 Redis 등 방법 생각해보기
        res.status(200).json({message: '인증 성공!!'});
    } else {
        res.status(400).json({message: '인증 실패'});
    }
}

// 사용자 정보 수정
exports.updateUser = async (req, res) => {

    try {
        const email = req.user.email;
        const { name, major, grade, residence } = req.body;

        const user = await userModel.findUserByEmail(email);
        if (!user) {
            return res.status(400).json({error: '해당 이메일의 사용자가 존재하지 않습니다.'});
        }

        await userModel.updateUserInfo(email, name, major, grade, residence);
        res.status(200).json({'message': '회원 정보 수정이 성공하였습니다.'});
    }
    catch (error) {
        console.error(error);
    }
}

// 사용자 비밀번호 수정
exports.updatePassword = async (req, res) => {

    try {
        const email = req.user.email;
        const { password, newPassword } = req.body;

        // 해당 이메일의 사용자가 있는지 확인
        const user = await userModel.findUserByEmail(email);
        if (!user) {
            return res.status(400).json({error: '해당 이메일의 사용자가 존재하지 않습니다.'});
        }
        
        // 입력한 비밀번호가 맞는지 확인
        const isPasswordValid = await bcrypt.compare(password, user.password); // 입력한 비밀번호와 암호화되어 저장된 비밀번호가 맞는지 확인
        if (!isPasswordValid) {
            return res.status(400).json({error: '입력하신 비밀번호가 맞지 않습니다.'});
        }

        // 비밀번호 해싱
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        
        // 비밀번호 수정
        await userModel.updateUserPassword(email, hashedPassword);
        res.status(200).json({'message': '비밀번호 수정이 성공하였습니다.'});
    }
    catch (error) {
        console.error(error);
    }
}

// 사용자 탈퇴
exports.deleteUser = async (req, res) => {

    try {
        const email = req.user.email;

        
        // 해당 이메일의 사용자가 있는지 확인
        const user = await userModel.findUserByEmail(email);
        if (!user) {
            return res.status(400).json({error: '해당 이메일의 사용자가 존재하지 않습니다.'});
        }

        // User 테이블에서 사용자 삭제
        await userModel.deleteUser(email);
        res.status(200).json({'message': '회원 삭제가 성공하였습니다.'});

    } catch (error) {
        console.error(error);
    }
}