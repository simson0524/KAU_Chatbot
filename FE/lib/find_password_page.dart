import 'package:flutter/material.dart';

class FindPasswordPage extends StatelessWidget {
  const FindPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 찾기 Page"),
      ),
      body: const Center(
        child: Text(
          "This is the 비밀번호 찾기 Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
