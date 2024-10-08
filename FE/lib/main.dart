import 'package:FE/character_page.dart';
import 'package:FE/character_provider.dart';
import 'package:FE/find_password_page.dart';
import 'package:flutter/material.dart';
import 'package:FE/join_page.dart';
import 'package:FE/api/auth_api.dart';
import 'package:provider/provider.dart'; // auth_api.dart 파일 추가하여 API 호출

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
    return const MaterialApp(
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
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
          const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  LoginImage(), //이미지
                  LoginInputFields(), //입력
                  LoginButtons(), // 버튼
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
  const LoginInputFields({super.key});

  @override
  State<LoginInputFields> createState() => _LoginInputFieldsState();
}

class _LoginInputFieldsState extends State<LoginInputFields> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final String domain = '@kau.kr';

  @override
  void initState() {
    super.initState();
    _idController.text = domain;
    _setCursorPosition();
  }

  // 커서를 이메일 입력 부분으로 제한
  void _setCursorPosition() {
    _idController.selection = TextSelection.fromPosition(
      TextPosition(offset: _idController.text.length - domain.length),
    );
  }

  // @kau.kr는 지우지 못하고 그 앞에만 수정 가능하게 설정
  void _cursorControl(String value) {
    if (!value.endsWith(domain)) {
      setState(() {
        _idController.text = value.split('@')[0] + domain;
        _setCursorPosition();
      });
    } else {
      _setCursorPosition();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
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
                  controller: _idController,
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
                      controller: _pwController,
                      obscureText: true, // 비밀번호 입력 시 가리기
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
  const LoginButtons({super.key});

  // 로그인 버튼 클릭 시 API 호출
  Future<void> _handleLogin(
      BuildContext context, String email, String password) async {
    try {
      // auth_api.dart 파일의 login 함수 호출
      await AuthApi.login(email, password);
      print('로그인 성공');
      // 로그인 성공 시 CharacterPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CharacterPage(), // 로그인 성공 시 이동할 페이지
        ),
      );
    } catch (error) {
      print('로그인 실패: $error');
      // 로그인 실패 시 경고창 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: OutlinedButton(
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: OutlinedButton(
                  child: const Text(
                    '비밀번호 찾기',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindPasswordPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
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
                // 로그인 버튼 클릭 시
                onPressed: () {
                  // 사용자가 입력한 이메일과 비밀번호
                  final email = 'user@kau.kr'; // 실제로는 사용자가 입력한 이메일을 사용
                  final password = 'password123'; // 실제로는 사용자가 입력한 비밀번호를 사용
                  _handleLogin(context, email, password); // 로그인 시도
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    width: 1.25,
                  ),
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
                  // 회원가입 버튼 클릭 시 회원가입 창으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    width: 1.25,
                  ),
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
        Offset(startX, y), // 아래쪽 y 위치에서 시작
        Offset(startX + dashWidth, y), // y 위치에서 끝
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


/*
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
*/