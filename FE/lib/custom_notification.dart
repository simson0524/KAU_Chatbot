import 'package:flutter/material.dart';

class CustomNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const CustomNotification({
    Key? key,
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 50.0), // 화면 상단 여백
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black87, // 배경색
          borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClose != null)
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
