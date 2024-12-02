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
          // Background Containers and Decorations
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
                        const SizedBox(height: 10),
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

// Image Widget
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

// Input Fields for Email and Password
class FindPWInput extends StatefulWidget {
  const FindPWInput({super.key});

  @override
  State<FindPWInput> createState() => _FindPWInputState();
}

bool isEmailVerified = false;

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
      _isobscured = !_isobscured;
    });
  }

  void _showcheckPW() {
    setState(() {
      _ischeckobscured = !_ischeckobscured;
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
    find_emailController.dispose();
    find_pwController.dispose();
    find_checkpwController.dispose();
    find_emailcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Email Input and Send Verification Code Button
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
                  String emailInput = find_emailController.text.trim();
                  if (emailInput == '@kau.kr' || emailInput.isEmpty) {
                    textmessageDialog(context, '이메일을 입력해주세요.');
                  } else {
                    try {
                      final response =
                          await AuthApi.sendEmailVerification(emailInput);
                      if (response.statusCode == 200) {
                        textmessageDialog(
                            context, '이메일 인증번호 메일을 보냈습니다.\n이메일을 확인해주세요.');
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
            ],
          ),
          const SizedBox(height: 5),
          // Verification Code Input and Confirm Button
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
                        controller: find_emailcodeController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: '인증번호 입력',
                          border: InputBorder.none,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final response = await AuthApi.verifyEmailCode(
                      find_emailController.text.trim(),
                      int.parse(find_emailcodeController.text.trim()),
                    );
                    if (response.statusCode == 200) {
                      setState(() {
                        isEmailVerified = true;
                      });
                      textmessageDialog(context, '이메일 인증이 완료되었습니다.');
                    } else {
                      textmessageDialog(
                          context, '인증번호가 맞지 않습니다.\n이메일과 인증번호를 다시 확인해주세요.');
                    }
                  } catch (error) {
                    textmessageDialog(context, '오류가 발생했습니다: $error');
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  visualDensity: VisualDensity(horizontal: 1.0, vertical: 1.0),
                  side: const BorderSide(color: Colors.black),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // New Password Input
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
          // Confirm New Password Input
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

// Navigate to Login Page
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

// Change Password Button
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
            print('[DEBUG] InputState is null. Returning early.');
            return;
          }
          if (inputState.nullcheck()) {
            print('[DEBUG] Null check failed. Some inputs are missing.');
            textmessageDialog(context, '입력되지 않은 값이 존재합니다');
            return;
          }
          if (!isEmailVerified) {
            textmessageDialog(context, '이메일 인증을 완료해주세요.');
            return;
          }
          if (!inputState.samePWcheck()) {
            print('[DEBUG] Password and confirmation do not match.');
            textmessageDialog(context, '비밀번호와 비밀번호 확인이 일치하지 않습니다');
            return;
          }
          try {
            print('[DEBUG] Attempting to change password...');
            print(
                '[DEBUG] Email: ${inputState.find_emailController.text.trim()}');
            print(
                '[DEBUG] New Password: ${inputState.find_pwController.text.trim()}');
            print(
                '[DEBUG] Confirm Password: ${inputState.find_checkpwController.text.trim()}');

            final response = await AuthApi.changePassword(
              email: inputState.find_emailController.text.trim(),
              newPassword: inputState.find_pwController.text.trim(),
              checkNewPassword: inputState.find_checkpwController.text.trim(),
            );

            if (response.containsKey('message')) {
              print(
                  '[DEBUG] Password changed successfully. Message: ${response['message']}');
              finishFindpwDialog(context);
            } else {
              print('[DEBUG] Password change failed. Response: $response');
              textmessageDialog(context, '비밀번호 변경에 실패했습니다. 다시 시도해주세요.');
            }
          } catch (error) {
            print('[ERROR] Exception occurred during password change: $error');
            textmessageDialog(context, '오류가 발생했습니다: $error');
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

// Dotted Line Painter
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

// Text Message Dialog
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
              child: Text(
                dialogmessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Password Change Success Dialog
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '비밀번호 변경이 완료되었습니다.\n다시 로그인 해주세요.',
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
