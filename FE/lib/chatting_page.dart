import 'package:FE/character_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  // 첫 안내 자동 메시지
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _receiveMessage(
          "안녕하세요. \n KAU CHATBOT입니다. \n 무엇이 궁금하시나요? \n 저에게 물어보세요! ");
    });
  }

  // 현재 날짜 가져오기
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy.MM.dd').format(now);
  }

  void _sendMessage() {
    String messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        messages.add({
          'message': messageText,
          'time': TimeOfDay.now().format(context),
          'isMine': true,
        });
      });
      _controller.clear();
    }
  }

  void _receiveMessage(String messageText) {
    setState(() {
      messages.add({
        'message': messageText,
        'time': TimeOfDay.now().format(context),
        'isMine': false,
      });
    });
  }

  // 캐릭터 따라 이미지 선택
  String _chatCharacterImage(String name) {
    if (name == '마일') {
      return 'assets/images/chat_mile.png';
    } else if (name == '마하') {
      return 'assets/images/chat_maha.png';
    } else {
      //피트
      return 'assets/images/chat_feet.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = Provider.of<CharacterProvider>(context).character;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'KAU CHATBOT',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 왼쪽상단바 버튼 동작 추가
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // 오른쪽상단바 버튼 동작 추가
            },
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          // 배경 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/grid_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              // 날짜 표시
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth: double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(
                      _getCurrentDate(),
                      style: TextStyle(color: Colors.black, fontSize: 10.0),
                    ),
                  ),
                ),
              ),

              // 채팅 내용
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(
                      profileImage: messages[index]['isMine']
                          ? ''
                          : _chatCharacterImage(
                              character), // Provider로 받은 이름에 따라 이미지 설정
                      name: messages[index]['isMine']
                          ? ''
                          : character, // Provider로 받은 이름 사용
                      message: messages[index]['message'],
                      time: messages[index]['time'],
                      isMine: messages[index]['isMine'],
                    );
                  },
                ),
              ),
              // 입력 필드와 전송 버튼
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '메세지를 입력하세요...',
                            ),
                            onSubmitted: (text) => _sendMessage(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.black),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String profileImage;
  final String name;
  final String message;
  final String time;
  final bool isMine;

  ChatBubble({
    required this.profileImage,
    required this.name,
    required this.message,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine && profileImage.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  profileImage,
                  width: 50,
                  height: 50,
                ),
                SizedBox(height: 4.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    SizedBox(height: 4.0),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(message),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          time,
                          style: TextStyle(color: Colors.grey, fontSize: 10.0),
                        )),
                  ],
                ),
              ],
            ),
          if (isMine)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(message),
                ),
              ],
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              time,
              style: TextStyle(color: Colors.grey, fontSize: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}
