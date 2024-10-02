import 'package:flutter/material.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("캐릭터선택 Page"),
      ),
      body: const Center(
        child: Text(
          "This is the 캐릭터선택 Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
