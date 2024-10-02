// import 'package:fe_view/character_page.dart';
import 'package:fe_view/find_password_page.dart';
import 'package:flutter/material.dart';
import 'package:fe_view/join_page.dart';

void main() {
  runApp(const MyApp());
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/grid_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const SingleChildScrollView(
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

// 입력 - 아이디,비밀번호
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

  //커서를 이메일입력부분으로 제한
  void _setCursorPosition() {
    _idController.selection = TextSelection.fromPosition(
      TextPosition(offset: _idController.text.length - domain.length),
    );
  }

//@kau.kr는 지우지 못하고 그 앞에만 수정가능하게
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
                      labelText: '아이디', border: InputBorder.none),
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
                          labelText: '비밀번호', border: InputBorder.none),
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
                // 로그인 버튼  클릭 시
                onPressed: () {
                  //if 로그인 실패 시 동작
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('알림'),
                        content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
                        actions: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: OutlinedButton(
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: OutlinedButton(
                              child: const Text(
                                '비밀번호 찾기',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FindPasswordPage(),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      );
                    },
                  );
                },

/*
                  // else 로그인 성공시 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterPage(),
                    ),
                  ); 
*/
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
                }, //버튼 디자인
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

//점선 표현
class DottedLineHorizontalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 90, 90, 90)
      ..strokeWidth = 1.5 // 두께
      ..style = PaintingStyle.stroke;

    const dashWidth = 8;
    const dashSpace = 4;

    double startX = 0;

    // y 좌표를 size.height로 설정하여 아래쪽에 점선을 그림
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