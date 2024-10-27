import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:FE/db/chat_dao.dart'; // ChatDao import for SQLite
import 'package:FE/api/chat_api.dart'; // ChatApi import for server interaction
import 'dart:convert';

class ChattingPage extends StatefulWidget {
  final String characterName;

  const ChattingPage({super.key, required this.characterName});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatDao _chatDao = ChatDao();
  String conversationId =
      "1"; // Example conversation ID, replace with actual logic
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    // Load messages from SQLite when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMessagesFromLocal();
    });
  }

  // Load messages from local SQLite
  Future<void> _loadMessagesFromLocal() async {
    final localMessages = await _chatDao.fetchMessages();

    if (localMessages.isEmpty) {
      // SQLite에 저장된 메시지가 없을 경우 환영 메시지 표시
      _receiveMessage("안녕하세요. \n KAU CHATBOT입니다. \n 무엇이 궁금하시나요? \n 저에게 물어보세요!");
    } else {
      setState(() {
        messages = localMessages;
      });
    }
  }

  // Store message in SQLite and send to server
  Future<void> _sendMessage() async {
    String messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      String currentTime = DateFormat('HH:mm').format(DateTime.now());

      // Add message to UI
      setState(() {
        messages.add({
          'message': messageText,
          'time': currentTime,
          'isMine': true,
        });
      });

      // Clear text field
      _controller.clear();

      // Save message locally in SQLite
      await _chatDao.insertMessage(messageText, "user", currentTime);

      // Send message to the server
      try {
        final response = await ChatApi.sendMessage(conversationId, messageText);
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          String botResponse = responseBody['message'] ?? 'No response';

          // Display the server response and save to SQLite
          _receiveMessage(botResponse);
          await _chatDao.insertMessage(botResponse, "bot", currentTime);
        }
      } catch (error) {
        print("Error sending message to server: $error");
      }
    }
  }

  // Receive message from the bot
  void _receiveMessage(String messageText) {
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    setState(() {
      messages.add({
        'message': messageText,
        'time': currentTime,
        'isMine': false,
      });
    });
  }

  // Helper to get current date
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy.MM.dd').format(now);
  }

  // Helper method to choose the correct character image
  String _chatCharacterImage() {
    if (widget.characterName == '마일') {
      return 'assets/images/chat_mile.png';
    } else if (widget.characterName == '마하') {
      return 'assets/images/chat_maha.png';
    } else if (widget.characterName == '피트') {
      return 'assets/images/chat_feet.png';
    } else {
      return 'assets/images/chat_basic.png'; // Default image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'KAU CHATBOT',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Add back button functionality
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Add menu functionality
            },
          ),
        ],
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.black),
        ),
      ),
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
              // Date display
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _getCurrentDate(),
                    style: const TextStyle(color: Colors.black, fontSize: 10.0),
                  ),
                ),
              ),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(
                      profileImage: messages[index]['isMine']
                          ? ''
                          : _chatCharacterImage(),
                      name:
                          messages[index]['isMine'] ? '' : widget.characterName,
                      message: messages[index]['message'],
                      time: messages[index]['time'],
                      isMine: messages[index]['isMine'],
                    );
                  },
                ),
              ),
              // Message input field and send button
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
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '메세지를 입력하세요...',
                          ),
                          onSubmitted: (text) => _sendMessage(),
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
                const SizedBox(height: 4.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
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
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10.0),
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
                  padding: const EdgeInsets.all(12.0),
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
              style: const TextStyle(color: Colors.grey, fontSize: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}
