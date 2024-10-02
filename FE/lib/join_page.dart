import 'package:flutter/material.dart';

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second Page"),
      ),
      body: const Center(
        child: Text(
          "This is the Second Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
