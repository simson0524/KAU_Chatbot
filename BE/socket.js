const { Server } = require('socket.io');

let io;

// `io` 초기화 함수
function initSocket(server) {
  io = new Server(server, {
    cors: {
      origin: '*', // 클라이언트 URL로 변경
    },
  });

  // 클라이언트 연결 이벤트
  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.id}`);

    // 사용자가 특정 룸에 가입
    socket.on('join', (student_id) => {
      console.log(`User ${student_id} joined room`);
      socket.join(student_id);
    });

    socket.on('disconnect', () => {
      console.log(`User disconnected: ${socket.id}`);
    });
  });

  return io;
}

// `io` 객체 가져오기
function getSocketIo() {
  if (!io) {
    throw new Error('Socket.io is not initialized!');
  }
  return io;
}

module.exports = { initSocket, getSocketIo };
