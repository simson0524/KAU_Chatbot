import 'dart:ui';

import 'package:FE/character_provider.dart';
import 'package:FE/main.dart';
import 'package:FE/pw_member_info.dart';
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

  //상단바 관련
  bool right_isDrawerOpen = false;

  void right_openDrawer() {
    setState(() {
      right_isDrawerOpen = !right_isDrawerOpen;
    });
  }

  void right_closeDrawer() {
    setState(() {
      right_isDrawerOpen = false;
    });
  }

  bool left_isDrawerOpen = false;

  void left_openDrawer() {
    setState(() {
      left_isDrawerOpen = !left_isDrawerOpen;
    });
  }

  void left_closeDrawer() {
    setState(() {
      left_isDrawerOpen = false;
    });
  }

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
        //왼쪽상단바
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: left_openDrawer,
        ),
        actions: [
          //오른쪽 상단바
          IconButton(
            icon: Icon(Icons.manage_accounts_outlined, color: Colors.black),
            onPressed: right_openDrawer,
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
          //오른쪽 상단바
          if (right_isDrawerOpen)
            GestureDetector(
              onTap: right_closeDrawer,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ],
              ),
            ),
          if (right_isDrawerOpen)
            Align(
              alignment: Alignment.topRight,
              child: Material(
                elevation: 5,
                child: Container(
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: right_DrawerWidget(onClose: right_closeDrawer),
                ),
              ),
            ),

          //왼쪽상단바
          if (left_isDrawerOpen)
            GestureDetector(
              onTap: left_closeDrawer,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ],
              ),
            ),
          if (left_isDrawerOpen)
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 5,
                child: Container(
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: left_DrawerWidget(onClose: left_closeDrawer),
                ),
              ),
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

class right_DrawerWidget extends StatelessWidget {
  final VoidCallback onClose;

  const right_DrawerWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Material(
        elevation: 5,
        child: Container(
          width: 250,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 1.0,
                color: Colors.black,
              ),
              Expanded(
                child: Column(
                  children: [
                    // 이미지
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 20.0),
                      height: 120,
                      child: Image.asset(
                        'assets/images/character_friend.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Divider(color: Colors.grey, thickness: 1.0),

                    // 회원정보 수정 버튼
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PwMemberInfo()),
                        );
                        onClose(); // 클릭 시 상단바 닫기
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6.0), // 위아래 여백 설정
                        child: Center(
                          child: Text(
                            '개인정보 수정',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    // 로그아웃 버튼
                    GestureDetector(
                      onTap: () {
                        showlogoutDialog(context);
                        onClose();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Text(
                            '로그아웃',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class left_DrawerWidget extends StatelessWidget {
  final VoidCallback onClose;

  const left_DrawerWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Material(
        elevation: 5,
        child: Container(
          width: 250,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Center(
            child: Text(
              '왼쪽상단바 10주차 진행',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

void showlogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), //테두리 모서리 둥글게
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: SizedBox(
          //dialog 사이즈
          width: 220,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3.0, top: 5.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '로그아웃을 하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  //로그아웃 - 네
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1.2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            '네',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      //로그아웃 - 아니요
                      Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1.2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            '아니요',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
