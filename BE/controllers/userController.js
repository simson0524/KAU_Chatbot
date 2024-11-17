const userService = require('../services/userService');
const userModel = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const redis = require('redis');
const { connect } = require('../config/dbConfig');

const redisClient = redis.createClient({
    url: 'redis://default:T8d3j86H8Vr9cyclTpS2qeGxvhAVxZOb@redis-17713.c323.us-east-1-2.ec2.redns.redis-cloud.com:17713/0',
    legacyMode: true
});

// redis 연결
async function connectRedis() {
    try {
        await redisClient.connect();
        console.info('Redis 서버에 연결되었습니다.');
    }
    catch (error) {
        console.error('Redis 서버 연결 에러: ', error);
    }
}

connectRedis();

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
        const accessToken = jwt.sign({student_id: user.student_id}, 'access-secretKey', {expiresIn: '1h'});
        const refreshToken = jwt.sign({student_id: user.student_id}, 'refresh-secretKey', {expiresIn: '1d'});

        await userModel.saveRefToken(user.student_id, refreshToken); // Refresh Token은 DB에 저장

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
        await redisClient.v4.setEx(email, 180, verificationNumber) // 인증번호를 3분간 redis에 저장
        await userService.transporter.sendMail(mailOptions)
        return res.status(200).json('이메일 보내기 성공');
    }
    catch (error) {
        console.error(error);
        return res.status(500).json('이메일 보내기 실패');
    }
}

// 이메일에 전송한 인증번호와 사용자가 입력한 인증번호가 같은지 확인
exports.verifyCode = async (req, res) => {
    const email = req.body.email;
    const code = req.body.code.toString();

    try {

        const storedCode = await redisClient.v4.get(email);

        if (storedCode === null) {
            return res.status(400).json('인증번호가 만료되었거나 존재하지 않습니다.');
        }

        // 저장된 인증번호와 입력한 인증번호가 일치한다면
        if (storedCode === code) {
            await redisClient.v4.del(email); // redis에서 해당 인증번호 삭제
            return res.status(200).json('인증번호가 확인되었습니다.');
        } else {
            return res.status(400).json('인증번호가 일치하지 않습니다.');
        }
        
    } catch (error) {
        console.error('인증번호 확인 중 오류: ', error);
        res.status(500).json('인증번호 확인 중 오류가 발생했습니다.');
    }
}

// 사용자 채팅 캐릭터 설정 페이지
exports.setCharacter = async (req, res) => {
    try {
        const { email, chat_character } = req.body;

        const user = await userModel.findUserByEmail(email);
        if (!user) {
            return res.status(400).json({error: '해당 이메일의 사용자가 존재하지 않습니다.'});
        }

        await userModel.updateUserCharacter(email, chat_character);
        res.status(200).json({'message': '사용자의 채팅 캐릭터 설정이 성공하였습니다.'});

    } catch (error) {
        console.error('채팅 캐릭터 설정 중 오류: ', error);
        res.status(500).json('채팅 캐릭터 설정 중 오류가 발생했습니다.');
    }
}

// 사용자 정보 가져오는 페이지
exports.getUserData = async (req, res) => {
    
    try {
        const student_id = req.user.student_id;
        const user = await userModel.findUserByStudentId(student_id);

        if (!user) {
            return res.status(404).json({error: '사용자가 존재하지 않습니다.'});
        }

        res.status(200).json(user);
        
    } catch (error) {
        console.error(error);
        res.status(500).json({'message': '회원 정보를 가져오기 못했습니다.'})
    }
}

// 사용자 정보 수정
exports.updateUser = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const { name, major, grade, residence } = req.body;

        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await userModel.updateUserInfo(student_id, name, major, grade, residence);
        res.status(200).json({'message': '회원 정보 수정이 성공하였습니다.'});
    }
    catch (error) {
        console.error(error);
        res.status(500).json('사용자 정보 수정 중 오류가 발생했습니다.');
    }
}

// 사용자 비밀번호 수정
exports.updatePassword = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const { password, new_password } = req.body;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }
        
        // 입력한 비밀번호가 맞는지 확인
        const isPasswordValid = await bcrypt.compare(password, user.password); // 입력한 비밀번호와 암호화되어 저장된 비밀번호가 맞는지 확인
        if (!isPasswordValid) {
            return res.status(400).json({error: '입력하신 비밀번호가 맞지 않습니다.'});
        }

        // 비밀번호 해싱
        const hashedPassword = await bcrypt.hash(new_password, 10);
        
        // 비밀번호 수정
        await userModel.updateUserPassword(student_id, hashedPassword);
        res.status(200).json({'message': '비밀번호 수정이 성공하였습니다.'});
    }
    catch (error) {
        console.error(error);
        res.status(500).json('사용자 비밀번호 수정 중 오류가 발생했습니다.');
    }
}

// 비밀번호 찾기 -> 새 비밀번호 생성해서 전달
exports.getNewPassword = async (req, res) => {
    try {
        const email = req.body.email;

        // 해당 이메일의 학생이 있는지 확인
        const user = await userModel.findUserByEmail(email);
        if (!user) {
            return res.status(400).json({error: '해당 이메일의 사용자가 존재하지 않습니다.'});
        }

        const tempPassword = userService.generateTempPassword();

        // 임시 비밀번호 해싱
        const hashedTempPassword = await bcrypt.hash(tempPassword, 10);
        
        // 임시 비밀번호 저장
        await userModel.updateUserPassword(user.student_id, hashedTempPassword);
        res.status(200).json({'message': '임시 비밀번호 전달을 성공하였습니다.', "임시 비밀번호": tempPassword});

    } catch (error) {
        console.error(error);
        res.status(500).json('사용자 비밀번호 찾기 중 오류가 발생했습니다.');
    }
}

// 사용자 탈퇴
exports.deleteUser = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        
        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        // User 테이블에서 사용자 삭제
        await userModel.deleteUser(student_id);
        res.status(200).json({'message': '회원 삭제가 성공하였습니다.'});

    } catch (error) {
        console.error(error);
        res.status(500).json('사용자 탈퇴 중 오류가 발생했습니다.');
    }
}

// access token 재발급
exports.getToken = async (req, res) => {

    try {
        const refreshToken = req.body.refresh_token;

        if (!refreshToken) {
            return res.status(401).json({'message': 'Refresh Token이 제공되지 않았습니다.'});
        }

        // 해당 refresh Token의 사용자가 있는지 확인
        const user = await userModel.findUserByToken(refreshToken);
        if (!user) {
            return res.status(400).json({error: '유효하지 않은 토큰입니다.'});
        }

        jwt.verify(refreshToken, 'refresh-secretKey', (err, user) => {
            if (err) {
                return res.status(403).json({'message': 'Refresh Token이 만료되었거나 유효하지 않습니다.'});
            }

            // Access Token 재발급
            const accessToken = jwt.sign({email: user.email}, 'access-secretKey', {expiresIn: '1h'});

            res.status(200).json({accessToken, "message": "토큰이 재발급 되었습니다."});
        })
    } catch (error) {
        console.error(error);
        res.status(500).json('토큰 재발급 중 오류가 발생했습니다.');
    }
    
}