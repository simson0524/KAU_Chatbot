import 'package:FE/find_password_page.dart';
import 'package:FE/member_info.dart';
import 'package:flutter/material.dart';
import 'package:FE/api/auth_api.dart'; // 본인 확인 API 가져오기
import 'package:shared_preferences/shared_preferences.dart';

class PwMemberInfo extends StatefulWidget {
  const PwMemberInfo({super.key});

  @override
  State<PwMemberInfo> createState() => _PwMemberInfoState();
}

class _PwMemberInfoState extends State<PwMemberInfo> {
  final TextEditingController pwMemberController = TextEditingController();
  String? email; // 이메일 정보 저장

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 사용자 정보 로드
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      Navigator.pop(context);
      return;
    }

    try {
      final userInfo = await AuthApi.getUserInfo(accessToken);
      setState(() {
        email = userInfo['email']; // 이메일 정보 설정
      });
    } catch (error) {
      print('Error loading user info: $error');
      textmessageDialog(context, '다시 시도해주세요.');
    }
  }

  Future<void> _verifyUser() async {
    if (email == null) {
      textmessageDialog(context, '이메일 정보를 불러오지 못했습니다.');
      return;
    }

    if (pwMemberController.text.isEmpty) {
      textmessageDialog(context, '비밀번호를 입력해주세요.');
      return;
    }

    try {
      final response = await AuthApi.checkUser(
        email: email!,
        password: pwMemberController.text,
      );

      if (response['message'] == '사용자 확인에 성공하였습니다.') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MemberInfo(),
          ),
        );
      } else {
        textmessageDialog(context, response['message'] ?? '다시 시도해주세요');
      }
    } catch (error) {
      print('Error verifying user: $error');
      textmessageDialog(context, '다시 시도해주세요');
    }
  }

  @override
  void dispose() {
    pwMemberController.dispose();
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
            Navigator.pop(context);
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이미지
                Container(
                  margin: EdgeInsets.only(bottom: 15.0),
                  width: 270,
                  height: 150,
                  child: Image.asset('assets/images/character_friend.png'),
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
                        controller: pwMemberController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '현재 비밀번호를 입력해주세요',
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _verifyUser,
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
