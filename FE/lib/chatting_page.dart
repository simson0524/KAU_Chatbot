import 'package:FE/character_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChattingPage extends StatelessWidget {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final character = Provider.of<CharacterProvider>(context).character;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatting Page'),
      ),
      body: Center(
        child: Text('선택한 캐릭터는: $character'),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 페이지'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('메시지 1'),
                ),
                ListTile(
                  title: Text('메시지 2'),
                ),
                // 여기에 채팅 내용을 추가
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // 메시지 전송 로직 구현
              },
            ),
          ],
        ),
      ),
    );
  }
  */
}
