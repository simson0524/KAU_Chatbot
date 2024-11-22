import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:FE/find_password_page.dart';
import 'package:flutter/material.dart';
import 'package:FE/join_page.dart';
import 'package:FE/api/auth_api.dart';
import 'package:provider/provider.dart'; // auth_api.dart 파일 추가하여 API 호출
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'PoorStory',
      ),
      title: 'login page',
      home: Scaffold(
        body: LoginPage(), // 로그인 페이지
      ),
    );
  }
}

// 로그인 페이지

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 생성
    final TextEditingController idController = TextEditingController();
    final TextEditingController pwController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/grid_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const LoginImage(),
                  // 컨트롤러를 전달하며 LoginInputFields를 호출
                  LoginInputFields(
                    idController: idController,
                    pwController: pwController,
                  ),
                  // LoginButtons에 컨트롤러 전달
                  LoginButtons(
                    idController: idController,
                    pwController: pwController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 이미지
class LoginImage extends StatelessWidget {
  const LoginImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 70, bottom: 15),
      child: Center(
        child: Image.asset('assets/images/login_image.png'),
      ),
    );
  }
}

// 입력 - 아이디, 비밀번호
class LoginInputFields extends StatefulWidget {
  // 컨트롤러를 받도록 수정
  final TextEditingController idController;
  final TextEditingController pwController;

  const LoginInputFields({
    required this.idController,
    required this.pwController,
    super.key,
  });

  @override
  State<LoginInputFields> createState() => _LoginInputFieldsState();
}

class _LoginInputFieldsState extends State<LoginInputFields> {
  final String domain = '@kau.kr';

  @override
  void initState() {
    super.initState();
    widget.idController.text = domain;
    _setCursorPosition();
  }

  void _setCursorPosition() {
    widget.idController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.idController.text.length - domain.length),
    );
  }

  void _cursorControl(String value) {
    if (!value.endsWith(domain)) {
      setState(() {
        widget.idController.text = value.split('@')[0] + domain;
        _setCursorPosition();
      });
    } else {
      _setCursorPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLineHorizontalPainter(),
                  ),
                ),
                TextFormField(
                  controller: widget.idController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: InputBorder.none,
                  ),
                  onChanged: _cursorControl,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLineHorizontalPainter(),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: widget.pwController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 버튼 - 로그인, 회원가입

class LoginButtons extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController pwController;

  const LoginButtons({
    required this.idController,
    required this.pwController,
    super.key,
  });

  Future<void> _handleLogin(
      BuildContext context, String email, String password) async {
    try {
      // AuthApi의 login 함수 호출
      final result = await AuthApi.login(email, password);

      // 로그인 성공 여부 확인 (result에서 직접 확인)
      if (result.containsKey('accessToken') &&
          result.containsKey('refreshToken')) {
        print('로그인 성공: ${result['message']}');

        // 로그인 성공 시 accessToken과 refreshToken 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result['accessToken'] ?? '');
        await prefs.setString('refreshToken', result['refreshToken'] ?? '');

        // 로그인 성공 시 페이지 이동

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChattingPage(), // 성공 시 이동할 페이지
          ),
        );
      } else {
        print('로그인 실패: ${result['message'] ?? '알 수 없는 오류'}');
        // 로그인 실패 시 알림창 표시
        showloginfailDialog(context); // 로그인 실패 시 다이얼로그 호출
      }
    } catch (error) {
      print('로그인 중 오류 발생: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: OutlinedButton(
                onPressed: () {
                  // 사용자가 입력한 이메일과 비밀번호를 전달 (도메인 포함)
                  final email = idController.text; // 도메인(@kau.kr) 포함된 이메일 사용
                  final password = pwController.text;
                  _handleLogin(context, email, password); // 로그인 시도
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white, // 흰색 배경 추가
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: OutlinedButton(
                onPressed: () {
                  // 회원가입 페이지로 이동하는 코드 (기존 기능 유지)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinPage(), // 회원가입 페이지로 이동
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white, // 흰색 배경 추가
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
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

void showloginfailDialog(BuildContext context) {
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
            padding:
                const EdgeInsets.only(bottom: 3.0, top: 5.0), //dialog의 내부 여백
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '아이디 또는 비밀번호가 맞지 않습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), //텍스트와 버튼 사이 간격
                  //재로그인 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 1.0),
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
                            '로그인',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), //버튼 사이 간격
                      //비밀번호 찾기
                      Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FindPasswordPage(),
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
                            '비밀번호 찾기',
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
