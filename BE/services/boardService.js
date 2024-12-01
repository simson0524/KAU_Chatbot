const boardModel = require('../models/boardModel');


// 사용자가 게시판의 작성자인지 확인하는 미들웨어
exports.isBoardAuthor = async (req, res, next) => {
    try {
        const boardId = req.params.board_id;
        const studentId = req.user.student_id;
    
        // 해당 id의 게시판이 있는지 확인
        const board = await boardModel.findBoardById(boardId);
    
        if (!board) {
            return res.status(404).json({'message': '미들웨어에서 해당 아이디의 게시판을 찾을 수 없습니다.'});
        }
        
        // 작성자 본인 확인
        if (board.author !== studentId) {
            return res.status(403).json({'message': '작성자 본인만 접근이 가능합니다.'});
        }

        // 작성자 본인이 맞으면 다음 미들웨어로 진행
        next();

    } catch (error) {
        console.error("작성자 확인 중 오류: ", error);
        res.status(500).json({'message': '작성자 확인 중 오류가 발생하였습니다.'});
    }
}