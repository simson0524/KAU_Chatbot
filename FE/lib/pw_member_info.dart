import 'package:FE/find_password_page.dart';
import 'package:FE/member_info.dart';
import 'package:flutter/material.dart';

class PwMemberInfo extends StatefulWidget {
  const PwMemberInfo({super.key});

  @override
  State<PwMemberInfo> createState() => _PwMemberInfoState();
}

class _PwMemberInfoState extends State<PwMemberInfo> {
  final TextEditingController pw_memberController = TextEditingController();

  @override
  void dispose() {
    pw_memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '개인 정보 수정',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 돌아가기
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 전체 여백 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: [
                // 이미지
                Container(
                  margin: EdgeInsets.only(bottom: 15.0), // 이미지와 입력 칸 사이 간격
                  width: 270, // 이미지 너비
                  height: 150, // 이미지 높이
                  child: Image.asset(
                      'assets/images/character_friend.png'), // 이미지 파일 경로
                ),
                // 입력 칸
                Container(
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 15.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DottedLineHorizontalPainter(),
                        ),
                      ),
                      TextField(
                        controller: pw_memberController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '현재 비밀번호를 입력해주세요',
                          border: InputBorder.none, // 기본 입력 필드 테두리 제거
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    /*  if (실패시){
                      textmessageDialog(context, '비밀번호가 일치하지 않습니다');
                    }
                    */
                    // if 추가시킨 후 아래 내용이 else부분
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MemberInfo()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      width: 1.25,
                    ),
                  ),
                  child: const Text(
                    '비밀번호 확인',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 점선 표현

class DottedLineHorizontalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 90, 90, 90)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8;
    const dashSpace = 4;

    double startX = 0;
    final y = size.height;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//텍스트 알림
void textmessageDialog(BuildContext context, String dialogmessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      //아무 클릭 없을 시 5초 뒤 자동으로 알림 닫기
      Future.delayed(const Duration(seconds: 5), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), //테두리 모서리 둥글게
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: SizedBox(
          //dialog 사이즈
          width: 150,
          height: 70,
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 3.0, top: 5.0), //dialog의 내부 여백
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dialogmessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
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
