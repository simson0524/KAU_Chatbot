const boardService = require('../services/boardService');
const boardModel = require('../models/boardModel');
const userModel = require('../models/userModel');


// 학과 게시판 조회
exports.getMajorBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier;

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
        const major_identifier = req.params.major_identifier;
        const board_id = req.params.board_id;

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
        const major_identifier = req.params.major_identifier;

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

        await boardModel.createComment(board_id, student_id, content);
        res.status(201).json({'message': '학과 게시판 댓글 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학과 게시판 댓글 생성 중 오류: ', error);
        res.status(500).json('학과 게시판 댓글 생성 중 오류가 발생했습니다.');
    }
}

// 학과 게시판 수정 페이지 가져오기
exports.getMajorBoardUpdate = async (req, res) => {
    try {
        const student_id = req.user.student_id;
        const major_identifier = req.params.major_identifier;
        const board_id = req.params.board_id;

        const board = await boardModel.getDetailBoard(board_id);
        res.status(200).json({'message': '학과 게시판 수정 페이지 조회에 성공하였습니다.', board});

    } catch (error) {
        console.error('학과 게시판 수정 페이지 조회 중 오류: ', error);
        res.status(500).json('학과 게시판 수정 페이지 조회 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 조회
exports.getStudentBoard = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier;

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
        const student_identifier = req.params.student_identifier;
        const board_id = req.params.board_id;

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
        const student_identifier = req.params.student_identifier;

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

        await boardModel.createComment(board_id, student_id, content);
        res.status(201).json({'message': '학번 게시판 댓글 생성이 성공하였습니다.'});
    }
    catch (error) {
        console.error('학번 게시판 댓글 생성 중 오류: ', error);
        res.status(500).json('학번 게시판 댓글 생성 중 오류가 발생했습니다.');
    }
}

// 학번 게시판 수정 페이지 가져오기
exports.getStudentBoardUpdate = async (req, res) => {

    try {
        const student_id = req.user.student_id;
        const student_identifier = req.params.student_identifier;
        const board_id = req.params.board_id;

        const board = await boardModel.getDetailBoard(board_id);
        res.status(200).json({'message': '학번 게시판 수정 페이지 조회에 성공하였습니다.', board});

    } catch (error) {
        console.error('학번 게시판 수정 페이지 조회 중 오류: ', error);
        res.status(500).json('학번 게시판 수정 페이지 조회 중 오류가 발생했습니다.');
    }
}

// 게시판 삭제
exports.deleteBoard = async (req, res) => {
    try {
        const board_id = req.params.board_id;
        const student_id = req.user.student_id;

        const result = await boardModel.deleteBoard(board_id);
        console.log(result);
        return res.status(200).json({'message': '게시판 삭제가 성공하였습니다.'});

    } catch (error) {
        console.error('게시판 삭제 중 오류: ', error);
        res.status(500).json('게시판 삭제 중 오류가 발생했습니다.');
    }
}

// 게시판 수정
exports.updateBoard = async (req, res) => {
    try {
        const board_id = req.params.board_id;
        const student_id = req.user.student_id;
        const { title, content } = req.body;

        await boardModel.updateBoard(board_id, title, content);
        res.status(200).json({'message': '게시판 수정이 성공하였습니다.'});

    } catch (error) {
        console.error('게시판 수정 중 오류: ', error);
        res.status(500).json('게시판 수정 중 오류가 발생했습니다.');
    }
}