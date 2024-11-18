const boardService = require('../services/boardService');
const boardModel = require('../models/boardModel');
const userModel = require('../models/userModel');


// 학과 게시판 조회
exports.getMajorBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        const boards = await boardModel.getMajorBoard(major_identifier);
        res.status(200).json({'message': '학과 게시판 조회에 성공하였습니다.', boards});

    } catch (error) {
        console.error('학과 게시판 조회 중 오류: ', error);
        res.status(500).json('학과 게시판 조회 중 오류가 발생했습니다.');
    }
}

// 학과 게시판 상세 조회
exports.getDetailMajorBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier
        const board_id = req.params.board_id;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        const board = await boardModel.getDetailBoard(board_id);
        const comments = await boardModel.getComments(board_id);
        res.status(200).json({'message': '게시판 상세 조회에 성공하였습니다.', board, comments});

    } catch (error) {
        console.error('게시판 상세 조회 중 오류: ', error);
        res.status(500).json('게시판 상세 조회 중 오류가 발생했습니다.');
    }
}

// 학과 게시판 생성
exports.createMajorBoard = async (req, res) => {

    try {
        const { title, content } = req.body;
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await boardModel.createMajorBoard(major_identifier, student_id, title, content);
        res.status(201).json({'message': '학과 게시판 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학과 게시판 생성 중 오류: ', error);
        res.status(500).json('학과 게시판 생성 중 오류가 발생했습니다.');
    }
}

// 학과 게시판 댓글 생성
exports.createMajorComments = async (req, res) => {

    try {
        const { content } = req.body;
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier;
        const board_id = req.params.board_id;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await boardModel.createComment(board_id, student_id, content);
        res.status(201).json({'message': '학과 게시판 댓글 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학과 게시판 댓글 생성 중 오류: ', error);
        res.status(500).json('학과 게시판 댓글 생성 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 조회
exports.getStudentBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        const boards = await boardModel.getStudentBoard(student_identifier);
        res.status(200).json({'message': '학번 게시판 조회에 성공하였습니다.', boards});

    } catch (error) {
        console.error('학과 게시판 조회 중 오류: ', error);
        res.status(500).json('학과 게시판 조회 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 상세 조회
exports.getDetailStudentBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier
        const board_id = req.params.board_id;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        const board = await boardModel.getDetailBoard(board_id);
        const comments = await boardModel.getComments(board_id);
        res.status(200).json({'message': '게시판 상세 조회에 성공하였습니다.', board, comments});

    } catch (error) {
        console.error('게시판 상세 조회 중 오류: ', error);
        res.status(500).json('게시판 상세 조회 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 생성
exports.createStudentIdBoard = async (req, res) => {

    try {
        const { title, content } = req.body;
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await boardModel.createStudentBoard(student_identifier, student_id, title, content);
        res.status(201).json({'message': '학번 게시판 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학번 게시판 생성 중 오류: ', error);
        res.status(500).json('학번 게시판 생성 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 댓글 생성
exports.createStudentComments = async (req, res) => {

    try {
        const { content } = req.body;
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier;
        const board_id = req.params.board_id;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await boardModel.createComment(board_id, student_id, content);
        res.status(201).json({'message': '학번 게시판 댓글 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학번 게시판 댓글 생성 중 오류: ', error);
        res.status(500).json('학번 게시판 댓글 생성 중 오류가 발생했습니다.');
    }
}

// 게시판 삭제
exports.deleteBoard = async (req, res) => {
    try {
        const board_id = req.params.board_id;
        const student_id = req.user.student_id;

        // 해당 학번의 사용자가 있는지 확인
        const user = await userModel.findUserByStudentId(student_id);
        if (!user) {
            return res.status(400).json({error: '해당 학번의 사용자가 존재하지 않습니다.'});
        }

        await boardModel.deleteBoard(board_id);
        res.status(204).json({'message': '게시판 삭제가 성공하였습니다.'});

    } catch (error) {
        console.error('게시판 삭제 중 오류: ', error);
        res.status(500).json('게시판 삭제 중 오류가 발생했습니다.');
    }
}