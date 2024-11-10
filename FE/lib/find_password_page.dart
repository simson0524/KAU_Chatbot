import 'dart:async';
import 'package:FE/api/auth_api.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';

final GlobalKey<_FindPWInputState> findPWInputKey =
    GlobalKey<_FindPWInputState>();

class FindPasswordPage extends StatelessWidget {
  const FindPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const FindPWImage(),
                        const SizedBox(height: 10), // 입력칸 시작 높이
                        Stack(
                          children: [
                            FindPWInput(key: findPWInputKey),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const go_login(),
                        const SizedBox(height: 20),
                        const FindPWfinish(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 이미지 위젯
class FindPWImage extends StatelessWidget {
  const FindPWImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 70),
      child: Center(
        child: Image.asset('assets/images/chatbot_login.png'),
      ),
    );
  }
}

// 입력 - 이메일, 비밀번호, 비밀번호 확인
class FindPWInput extends StatefulWidget {
  const FindPWInput({super.key});

  @override
  State<FindPWInput> createState() => _FindPWInputState();
}

class _FindPWInputState extends State<FindPWInput> {
  final TextEditingController find_emailController = TextEditingController();
  final TextEditingController find_pwController = TextEditingController();
  final TextEditingController find_checkpwController = TextEditingController();
  final TextEditingController find_emailcodeController =
      TextEditingController();
  final domain = '@kau.kr';

  bool _isobscured = true;
  bool _ischeckobscured = true;

  @override
  void initState() {
    super.initState();
    find_emailController.text = domain;
    _setCursorPosition();
  }

  void _showPW() {
    setState(() {
      _isobscured = false;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isobscured = true;
      });
    });
  }

  void _showcheckPW() {
    setState(() {
      _ischeckobscured = false;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _ischeckobscured = true;
      });
    });
  }

  Widget buildOutlineButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      ),
    );
  }

  bool samePWcheck() {
    return find_pwController.text == find_checkpwController.text;
  }

  bool nullcheck() {
    String emailinput = find_emailController.text.split('@')[0];
    return emailinput.isEmpty ||
        find_pwController.text.isEmpty ||
        find_checkpwController.text.isEmpty ||
        find_emailcodeController.text.isEmpty;
  }

  void _setCursorPosition() {
    find_emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: find_emailController.text.length - domain.length),
    );
  }

  void _cursorControl(String value) {
    if (!value.endsWith(domain)) {
      setState(() {
        find_emailController.text = value.split('@')[0] + domain;
        _setCursorPosition();
      });
    } else {
      _setCursorPosition();
    }
  }

  @override
  void dispose() {
    find_emailController.clear();
    find_pwController.clear();
    find_checkpwController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 7,
                child: Container(
                  margin: const EdgeInsets.only(left: 50.0, right: 0.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DottedLineHorizontalPainter(),
                        ),
                      ),
                      TextFormField(
                        controller: find_emailController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            labelText: '이메일 입력', border: InputBorder.none),
                        onChanged: _cursorControl,
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String emailinput = find_emailController.text.trim();
                  if (emailinput == '@kau.kr' || emailinput.isEmpty) {
                    textmessageDialog(context, '이메일을 입력해주세요.');
                  } else {
                    try {
                      final response =
                          await AuthApi.sendEmailVerification(emailinput);
                      if (response.statusCode == 200) {
                        textmessageDialog(
                            context, '이메일 인증번호 메일을 보냈습니다. \n 이메일을 확인해주세요.');
                      } else {
                        textmessageDialog(
                            context, '이메일 전송에 실패했습니다. 다시 시도해주세요.');
                      }
                    } catch (error) {
                      textmessageDialog(context, '오류가 발생했습니다: $error');
                    }
                  }
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text(
                  '인증번호\n    발송',
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10.0),
              Flexible(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DottedLineHorizontalPainter(),
                        ),
                      ),
                      TextFormField(
                        controller: find_emailcodeController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: '인증번호 입력',
                          border: InputBorder.none,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                left: 75,
                top: 10,
                bottom: 10,
                child: TextButton(
                  onPressed: () async {
                    try {
                      final response = await AuthApi.verifyEmailCode(
                        find_emailController.text.trim(),
                        int.parse(find_emailcodeController.text.trim()),
                      );
                      if (response.statusCode == 200) {
                        textmessageDialog(context, '이메일 인증이 확인되었습니다.');
                      } else {
                        textmessageDialog(
                            context, '인증번호가 맞지 않습니다. \n 이메일과 인증번호를 다시 확인해주세요.');
                      }
                    } catch (error) {
                      textmessageDialog(context, '오류가 발생했습니다: $error');
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 2.0),
                    visualDensity:
                        VisualDensity(horizontal: 1.0, vertical: 1.0),
                    side: const BorderSide(color: Colors.black),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLineHorizontalPainter(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: find_pwController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            labelText: '새 비밀번호', border: InputBorder.none),
                        obscureText: _isobscured,
                      ),
                    ),
                    const SizedBox(width: 10),
                    buildOutlineButton('비밀번호 보기', _showPW),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLineHorizontalPainter(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: find_checkpwController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            labelText: '새 비밀번호 확인', border: InputBorder.none),
                        obscureText: _ischeckobscured,
                      ),
                    ),
                    const SizedBox(width: 10),
                    buildOutlineButton('비밀번호 보기', _showcheckPW),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 로그인 페이지로 이동
class go_login extends StatelessWidget {
  const go_login({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            child: const Text(
              '로그인 페이지로',
              style: TextStyle(fontSize: 10, color: Colors.black),
            )),
      ),
    );
  }
}

// 비밀번호 변경 버튼
class FindPWfinish extends StatelessWidget {
  const FindPWfinish({super.key});

  @override
  Widget build(BuildContext context) {
    final _FindPWInputState? inputState = findPWInputKey.currentState;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10, right: 100, left: 100),
      child: OutlinedButton(
        onPressed: () async {
          if (inputState == null) {
            return;
          }
          if (inputState.nullcheck()) {
            textmessageDialog(context, '입력되지 않은 값이 존재합니다');
            return;
          }
          if (inputState.samePWcheck()) {
            try {
              final response = await AuthApi.changePassword(
                inputState.find_pwController.text.trim(),
                inputState.find_checkpwController.text.trim(),
              );
              if (response.statusCode == 200) {
                finishFindpwDialog(context);
              } else {
                textmessageDialog(context, '비밀번호 변경에 실패했습니다. 다시 시도해주세요.');
              }
            } catch (error) {
              textmessageDialog(context, '오류가 발생했습니다: $error');
            }
          } else {
            textmessageDialog(context, '비밀번호와 비밀번호 확인이 일치하지 않습니다');
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            width: 1.25,
          ),
        ),
        child: const Text(
          '비밀번호 변경',
          style: TextStyle(fontSize: 15, color: Colors.black),
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

// 텍스트 알림
void textmessageDialog(BuildContext context, String dialogmessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 5), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: SizedBox(
          width: 150,
          height: 70,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3.0, top: 5.0),
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

// 비밀번호 변경 성공 알림창
void finishFindpwDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 5), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: SizedBox(
          width: 220,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3.0, top: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '비밀번호 변경이 완료되었습니다. \n 다시 로그인 해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1.2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
