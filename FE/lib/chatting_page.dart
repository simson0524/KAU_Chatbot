import 'dart:ui';

import 'package:FE/character_provider.dart';
import 'package:FE/left_board/college_num_community/college_num.dart';
import 'package:FE/left_board/external_site/external_site.dart';
import 'package:FE/left_board/qna_board/qna_board.dart';
import 'package:FE/left_board/notice_board/notice_board.dart';
import 'package:FE/left_board/major_community/major_board.dart';
import 'package:FE/main.dart';
import 'package:FE/pw_member_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:FE/db/chat_dao.dart'; // ChatDao import for SQLite
import 'package:FE/api/chat_api.dart'; // ChatApi import for server interaction
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:FE/api/auth_api.dart';
import 'package:url_launcher/url_launcher.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatDao _chatDao = ChatDao();
  late String token;
  int chatId = 0;
  List<Map<String, dynamic>> messages = [];
  late ScrollController _scrollController; //스크롤컨트롤러 추가
  final FocusNode _focusNode = FocusNode(); //포커스노드 추가
// Initialize token and chatId
  late String chatCharacter = 'maha'; // 기본값 설정

  //상단바 관련
  bool right_isDrawerOpen = false;

  bool left_isDrawerOpen = false;

  // 첫 안내 자동 메시지
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange); //포커스 변화 감지 리스너 추가

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isInitialized = await _initializeChat();
      if (isInitialized) {
        await _loadMessagesFromLocal();
      } else {
        // Navigate to login or show an error message if needed
        print("Initialization failed. Token is missing.");
      }
    });
  }

  //스크롤 관련
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  //스크롤 관련
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // 스크롤컨트롤러 해제
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("accessToken") ?? ''; // Token 가져오기

    if (token.isEmpty) {
      print("Token is missing. Please login.");
      return false; // Token이 없으면 초기화 실패
    }

    try {
      // 서버에서 회원 정보 가져오기
      final userInfo = await AuthApi.getUserInfo(token);
      setState(() {
        chatCharacter =
            userInfo['chat_character'] ?? 'maha'; // chat_character 설정
      });
      print("캐릭터 설정됨: $chatCharacter");
      return true; // 성공적으로 초기화
    } catch (error) {
      print("Error fetching user info: $error");
      return false; // 서버 요청 실패
    }
  }

  // Load messages from local SQLite
  Future<void> _loadMessagesFromLocal() async {
    final localMessages = await _chatDao.fetchAllMessages(); // 모든 메시지를 불러오기
    if (localMessages.isEmpty) {
      // 캐릭터별 첫 안내 메시지 설정
      if (chatCharacter == 'maha') {
        _receiveMessage(
            "안녕하세요. \n KAU CHATBOT입니다. \n 무엇이 궁금하시나요? \n 저에게 물어보세요!");
      } else if (chatCharacter == 'mile') {
        _receiveMessage(
            "Hello. \n I'm KAU CHATBOT. \n What do you want to know? \n Ask me!");
      } else if (chatCharacter == 'feet') {
        _receiveMessage("你好。 \n 这里是KAU CHATBOT  \n 你想知道什么？ \n 问我吧");
      } else {
        // 기본 안내 메시지 설정 (예: 캐릭터가 없을 경우)
        _receiveMessage(
            "안녕하세요. \n KAU CHATBOT입니다. \n 무엇이 궁금하시나요? \n 저에게 물어보세요!");
      }
    } else {
      setState(() {
        messages = localMessages.map((msg) {
          return {
            'message': msg['message'],
            'time': msg['timestamp'],
            'isMine': msg['sender'] == 'user', // sender 값을 기반으로 isMine 설정
            'character': msg['character'],
          };
        }).toList();
      });
    }
  }

  // Store message in SQLite and send to server
  Future<void> _sendMessage() async {
    String messageText = _controller.text.trim();
    if (messageText.isNotEmpty && token.isNotEmpty) {
      // Full timestamp with date and time
      String fullTimestamp =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      // Extract time for UI display
      String displayTime = DateFormat('HH:mm').format(DateTime.now());

      setState(() {
        messages.add({
          'message': messageText,
          'time': fullTimestamp, // UI에 표시할 시간만 추가
          'isMine': true,
          'character': chatCharacter,
        });
      });
      _controller.clear();

      // 메시지 추가 후 스크롤 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Get a new chatId for the response
      chatId = await _chatDao.getNewChatId();

      await _chatDao.insertMessage(
        messageText,
        "user",
        fullTimestamp, // SQLite에 전체 timestamp 저장
        chatId,
        chatCharacter,
      );

      try {
        // API 호출 및 응답 처리
        final response =
            await ChatApi.sendQuestion(token, messageText, chatCharacter);

        // 서버 응답에서 answer 추출
        String botAnswer = response['answer']; // 응답의 'answer' 필드 사용
        _receiveMessage(botAnswer);
      } catch (error) {
        print("Error sending question to server: $error");
      }
    }
  }

// Display bot's response and store it in SQLite
  void _receiveMessage(String messageText) async {
    // Full timestamp with date and time
    String fullTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    // Extract time for UI display
    String displayTime = DateFormat('HH:mm').format(DateTime.now());

    // Get a new chatId for the response
    chatId = await _chatDao.getNewChatId();

    setState(() {
      messages.add({
        'message': messageText,
        'time': fullTimestamp, // UI에 표시할 시간만 추가
        'isMine': false,
        'character': chatCharacter,
      });
    });

    _scrollToBottom(); // 새로운 메시지 추가 후 스크롤

    // Store the bot's response in SQLite
    await _chatDao.insertMessage(
      messageText,
      "bot",
      fullTimestamp, // SQLite에 전체 timestamp 저장
      chatId,
      chatCharacter,
    );
  }

// Helper to get current date
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy.MM.dd').format(now);
  }

  // UI and other methods remain unchanged...

  // Helper method to choose the correct character image
  String _chatCharacterImage() {
    if (chatCharacter == 'mile') {
      return 'assets/images/chat_mile.png';
    } else if (chatCharacter == 'maha') {
      return 'assets/images/chat_maha.png';
    } else if (chatCharacter == 'feet') {
      return 'assets/images/chat_feet.png';
    } else {
      return 'assets/images/chat_maha.png'; // Default image
    }
  }

  // Toggle drawer states for UI
  void right_openDrawer() {
    setState(() {
      right_isDrawerOpen = !right_isDrawerOpen;
    });
  }

  void right_closeDrawer() => setState(() => right_isDrawerOpen = false);

  void left_openDrawer() {
    setState(() {
      left_isDrawerOpen = !left_isDrawerOpen;
    });
  }

  void left_closeDrawer() => setState(() => left_isDrawerOpen = false);

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // 포커스가 활성화될 때 스크롤 이동
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 상태바 배경 흰색
        statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 어두운 색상
      ),
    );

    _scrollController = ScrollController(); //스크롤 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    double keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; //키보드 높이 감지

    SystemChrome.setSystemUIOverlayStyle(//앱바 배경관련
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.white));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
          ),
        ),
        elevation: 0.0,
        title: Text(
          'KAU CHATBOT',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: left_openDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_accounts_outlined, color: Colors.black),
            onPressed: right_openDrawer,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.black),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/grid_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // Chat messages
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 빈 화면을 터치하면 키보드 닫힘
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView.builder(
                    controller: _scrollController, //스크롤컨트롤러 연결
                    physics: const BouncingScrollPhysics(), // 부드러운 스크롤 효과
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isMine =
                          messages[index]['isMine'] ?? false; // 기본값 false 추가

                      return ChatBubble(
                        profileImage: isMine ? '' : _chatCharacterImage(),
                        name: isMine ? '' : chatCharacter,
                        message: messages[index]['message'],
                        time: messages[index]['time'],
                        isMine: isMine,
                      );
                    },
                  ),
                ),
              ),

              // Message input field and send button
              Padding(
                padding: EdgeInsets.only(
                  bottom: 4.0,
                  left: 8.0,
                  right: 8.0,
                  top: 4.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '메세지를 입력하세요...',
                          ),
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              _sendMessage(); // Enter 키 입력 시 메시지 전송
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Right drawer
          if (right_isDrawerOpen) ...[
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
            Align(
              alignment: Alignment.topRight,
              child: Material(
                elevation: 5,
                child: Container(
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: RightDrawerWidget(onClose: right_closeDrawer),
                ),
              ),
            ),
          ],
          // Left drawer
          if (left_isDrawerOpen) ...[
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
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 5,
                child: Container(
                  width: 250,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: LeftDrawerWidget(onClose: left_closeDrawer),
                ),
              ),
            ),
          ],
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

  const ChatBubble({
    required this.profileImage,
    required this.name,
    required this.message,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    // URL 감지
    final urlRegex = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    // 메시지를 텍스트 스팬으로 변환
    List<TextSpan> messageSpans = [];
    int start = 0;
    final matches = urlRegex.allMatches(message);

    for (final match in matches) {
      if (match.start > start) {
        messageSpans.add(TextSpan(
          text: message.substring(start, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      final url = message.substring(match.start, match.end);
      messageSpans.add(TextSpan(
        text: url,
        style: const TextStyle(
            color: Colors.blue, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()
          ..onTap =
              () => _launchUrl(url.startsWith('http') ? url : 'http://$url'),
      ));

      start = match.end;
    }

    if (start < message.length) {
      messageSpans.add(TextSpan(
        text: message.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

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
                const SizedBox(width: 8.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.black),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: SelectableText.rich(
                          TextSpan(
                            children: messageSpans,
                            style: const TextStyle(color: Colors.black),
                          ),
                          textAlign: TextAlign.left,
                          maxLines: null,
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(FocusNode()); // 포커스 다시 설정
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SelectableText(
                          time,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (isMine)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: SelectableText.rich(TextSpan(
                    children: messageSpans,
                    style: const TextStyle(color: Colors.black),
                  )),
                ),
              ],
            ),
          if (isMine)
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 10.0),
              ),
            ),
        ],
      ),
    );
  }

  // URL 열기 함수
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

// Right drawer widget
class RightDrawerWidget extends StatelessWidget {
  final VoidCallback onClose;

  const RightDrawerWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: Container(
        width: 250,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            // Image and title
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              height: 120,
              child: Image.asset(
                'assets/images/character_friend.png',
                fit: BoxFit.cover,
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1.0),

            // Edit profile button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PwMemberInfo()),
                );
                onClose(); // Close drawer after navigation
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: const Center(
                  child: Text(
                    '개인정보 수정',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1.0),

            // Logout button
            GestureDetector(
              onTap: () {
                showLogoutDialog(context);
                onClose();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: const Center(
                  child: Text(
                    '로그아웃',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1.0),
          ],
        ),
      ),
    );
  }
}

// Left drawer widget
class LeftDrawerWidget extends StatelessWidget {
  final VoidCallback onClose;

  const LeftDrawerWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
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
                  //학교 공지 게시판
                  boardNavigation(
                      context, '학교 공지 게시판', NoticeBoardPage(), onClose),
                  Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  ),
                  // 외부사이트 게시판
                  boardNavigation(
                      context, '외부 사이트 게시판', ExternalBoardPage(), onClose),
                  Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  ),
                  // 학과별 커뮤니티 게시판
                  boardNavigation(
                      context, '학과별 커뮤니티 게시판', MajorBoard(), onClose),
                  Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  ),
                  //학번별 커뮤니티 게시판
                  boardNavigation(
                      context, '학번별 커뮤니티 게시판', CollegeNum(), onClose),
                  Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  ),
                  //학교 문의 게시판
                  boardNavigation(
                      context, '학교 문의 게시판', QnaBoardPage(), onClose),
                  Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  ),
                  // 이미지
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: 120,
                    child: Image.asset(
                      'assets/images/character_friend.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Logout dialog
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: SizedBox(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Confirm logout
                      Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
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
                      // Cancel logout
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

Widget boardNavigation(
    BuildContext context, String text, Widget page, VoidCallback onClose) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
      onClose();
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ),
  );
}
