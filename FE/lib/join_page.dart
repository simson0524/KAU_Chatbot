import 'dart:async';

import 'package:FE/character_page.dart';
import 'package:FE/chatting_page.dart';
import 'package:FE/find_password_page.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:FE/api/auth_api.dart';
import 'dart:convert';

final GlobalKey<_JoinInputState> joinPWInputKey = GlobalKey<_JoinInputState>();

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

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
                        const JoinImage(),
                        const SizedBox(height: 0),
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: JoinInput(key: joinPWInputKey),
                            ),
                            /*const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: 70, right: 20),
                                child: Joinbutton(),
                              ),
                            ),*/
                          ],
                        ),
                        const SizedBox(height: 10),
                        const go_login(),
                        const SizedBox(height: 10),
                        const Joinfinish()
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

//이미지
class JoinImage extends StatelessWidget {
  const JoinImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 70),
      child: Center(
        child: Image.asset('assets/images/chatbot_image.png'),
      ),
    );
  }
}

//입력 - 학번,이메일,비밀번호,비밀번호 확인, 이름, 성별, 전공, 학년
class JoinInput extends StatefulWidget {
  const JoinInput({super.key});

  @override
  State<JoinInput> createState() => _JoinInputState();
}

bool isEmailVerified = false;

class _JoinInputState extends State<JoinInput> {
  final TextEditingController join_numberController = TextEditingController();
  final TextEditingController join_nameController = TextEditingController();
  final TextEditingController join_emailController = TextEditingController();
  final TextEditingController join_emailcodeController =
      TextEditingController();
  final TextEditingController join_pwController = TextEditingController();
  final TextEditingController join_checkpwController = TextEditingController();
  final TextEditingController join_homeController = TextEditingController();
  final TextEditingController join_majorController = TextEditingController();

  String? join_Gender;
  String? join_Grade;
  final domain = '@kau.kr';

  bool _isobscured = true;
  bool _ischeckobscured = true;

  @override
  void initState() {
    super.initState();
    join_emailController.text = domain;
    _setCursorPosition();
  }

  //비밀번호 보기 버튼 관련
  void _showPW() {
    setState(() {
      _isobscured = false;
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        _isobscured = true;
      });
    });
  }

  //비밀번호 보기 버튼 관련
  void _showcheckPW() {
    setState(() {
      _ischeckobscured = false;
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        _ischeckobscured = true;
      });
    });
  }

  //비밀번호 보기 버튼
  Widget buildOutlineButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
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

  //비밀번호 일치 여부 검증
  bool samePWcheck() {
    return join_pwController.text == join_checkpwController.text;
  }

  //null값 여부
  bool nullcheck() {
    String emailinput = join_emailController.text.split('@')[0];

    return emailinput.isEmpty ||
        join_numberController.text.isEmpty ||
        join_nameController.text.isEmpty ||
        join_pwController.text.isEmpty ||
        join_emailcodeController.text.isEmpty ||
        join_checkpwController.text.isEmpty ||
        join_homeController.text.isEmpty ||
        join_majorController.text.isEmpty ||
        join_Gender == null ||
        join_Grade == null;
  }

  //커서를 이메일입력부분으로 제한
  void _setCursorPosition() {
    join_emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: join_emailController.text.length - domain.length),
    );
  }

  //@kau.kr는 지우지 못하고 그 앞에만 수정가능하게
  void _cursorControl(String value) {
    if (!value.endsWith(domain)) {
      setState(() {
        join_emailController.text = value.split('@')[0] + domain;
        _setCursorPosition();
      });
    } else {
      _setCursorPosition();
    }
  }

  @override
  void dispose() {
    join_numberController.clear();
    join_emailController.clear();
    join_emailcodeController.clear();
    join_pwController.clear();
    join_checkpwController.clear();
    join_nameController.clear();
    join_majorController.clear();
    join_homeController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        //학번
        Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DottedLineHorizontalPainter(),
                      ),
                    ),
                    TextFormField(
                      controller: join_numberController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), //숫자만 입력할 수 있게 설정
                      ],
                      decoration: const InputDecoration(
                          labelText: '학번',
                          hintText: '숫자로 입력해주세요',
                          border: InputBorder.none),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        height: 55,
                        child: CustomPaint(
                          painter: DottedLineHorizontalPainter(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: join_nameController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                              labelText: '이름', border: InputBorder.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이메일 입력칸
            Flexible(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.only(left: 30.0, right: 0.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DottedLineHorizontalPainter(),
                      ),
                    ),
                    TextFormField(
                      controller: join_emailController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: '이메일 입력', border: InputBorder.none),
                      onChanged: _cursorControl,
                    ),
                  ],
                ),
              ),
            ),

            // 인증번호 발송 버튼에 기능 추가
            TextButton(
              onPressed: () async {
                String emailinput = join_emailController.text.trim();
                if (emailinput == '@kau.kr' || emailinput.isEmpty) {
                  textmessageDialog(context, '이메일을 입력해주세요.');
                } else {
                  try {
                    final response =
                        await AuthApi.sendEmailVerification(emailinput);
                    if (response.statusCode == 200) {
                      textmessageDialog(
                          context, '이메일 인증번호를 전송했습니다. 이메일을 확인해주세요.');
                    } else {
                      textmessageDialog(
                          context, '이메일 인증번호 전송에 실패했습니다. 다시 시도해주세요.');
                    }
                  } catch (error) {
                    textmessageDialog(context, '이메일 인증 중 오류가 발생했습니다.');
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
                side: BorderSide(color: Colors.black),
              ),
              child: const Text(
                '인증번호\n발송',
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),

            const SizedBox(width: 10.0), // 칸 사이 간격

            // 인증번호 입력칸
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
                      controller: join_emailcodeController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: '인증번호 입력',
                        border: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                      onChanged: (value) {
                        /*
                if (인증번호 맞을 시){
                  textmessageDialog(context, '이메일 인증이 확인되었습니다.');
                } else{
                  textmessageDialog(context, '인증번호가 맞지 않습니다. \n 이메일과 인증번호를 다시 확인해주세요')
                }
                */
                      },
                    ),
                  ],
                ),
              ),
            ),
            // 확인 버튼
            // 인증 코드 확인 버튼에 기능 추가
            Positioned(
              right: 0,
              left: 75,
              top: 10,
              bottom: 10,
              child: TextButton(
                onPressed: () async {
                  try {
                    final code =
                        int.tryParse(join_emailcodeController.text.trim());
                    final email = join_emailController.text.trim();

                    if (code == null) {
                      textmessageDialog(context, '인증번호를 올바르게 입력해주세요.');
                      return;
                    }

                    final response = await AuthApi.verifyEmailCode(email, code);
                    if (response.statusCode == 200) {
                      setState(() {
                        isEmailVerified = true;
                      });
                      textmessageDialog(context, '이메일 인증이 완료되었습니다.');
                    } else {
                      textmessageDialog(context, '인증번호가 일치하지 않습니다.');
                    }
                  } catch (error) {
                    textmessageDialog(context, '이메일 인증 중 오류가 발생했습니다.');
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  visualDensity: VisualDensity(horizontal: 1.0, vertical: 1.0),
                  side: BorderSide(color: Colors.black),
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

        //비밀번호
        const SizedBox(height: 2),
        Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                      controller: join_pwController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: '비밀번호 입력', border: InputBorder.none),
                      obscureText: _isobscured,
                    ),
                  ),
                  SizedBox(width: 10),
                  buildOutlineButton('비밀번호 보기', _showPW),
                ],
              ),
            ],
          ),
        ),
        //비밀번호 확인
        const SizedBox(height: 2),
        Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                      controller: join_checkpwController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: '비밀번호 확인', border: InputBorder.none),
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
        const SizedBox(height: 2),
        //거주지와 성별 가로 정렬
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //거주지
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DottedLineHorizontalPainter(),
                      ),
                    ),
                    TextFormField(
                      controller: join_homeController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: '거주지', border: InputBorder.none),
                    ),
                  ],
                ),
              ),
              //성별
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 40,
                        height: 55,
                        child: Positioned.fill(
                          child: CustomPaint(
                            painter: DottedLineHorizontalPainter(),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 55,
                        width: 40,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '남/여',
                            border: InputBorder.none,
                          ),
                          value: join_Gender,
                          //아이콘을 없애고 해당 부분 클릭시 뜨게
                          icon: null,
                          iconSize: 0,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          items: ['남', '여'].map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Center(child: Text(gender)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              join_Gender = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        //전공과 학년 가로 정렬
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //전공
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DottedLineHorizontalPainter(),
                      ),
                    ),
                    TextFormField(
                      controller: join_majorController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: '전공', border: InputBorder.none),
                    ),
                  ],
                ),
              ),
              //학년
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 40,
                        height: 55,
                        child: CustomPaint(
                          painter: DottedLineHorizontalPainter(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 55,
                        width: 40,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '학년',
                            border: InputBorder.none,
                          ),
                          value: join_Grade,
                          icon: null,
                          iconSize: 0,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          items:
                              ['1', '2', '3', '4', '기타'].map((String number) {
                            return DropdownMenuItem<String>(
                              value: number,
                              child: Center(child: Text(number)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              join_Grade = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class go_login extends StatelessWidget {
  const go_login({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                child: const Text(
                  '로그인 페이지로',
                  style: TextStyle(fontSize: 10, color: Colors.black),
                )),
          ],
        ),
      ),
    );
  }
}

//회원가입 완료 버튼

class Joinfinish extends StatelessWidget {
  const Joinfinish({super.key});

  @override
  Widget build(BuildContext context) {
    final _JoinInputState? inputState = joinPWInputKey.currentState;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10, right: 120, left: 120),
      child: OutlinedButton(
        onPressed: () async {
          if (inputState == null) {
            textmessageDialog(context, '입력 상태를 가져오지 못했습니다.');
            return;
          }

          if (inputState.nullcheck()) {
            textmessageDialog(context, '입력되지 않은 값이 존재합니다.');
            return;
          }

          if (!inputState.samePWcheck()) {
            textmessageDialog(context, '비밀번호와 비밀번호 확인이 일치하지 않습니다.');
            return;
          }

          // 이메일 인증 여부 확인
          if (!isEmailVerified) {
            textmessageDialog(context, '이메일 인증을 완료해주세요.');
            return;
          }

          final studentId = int.tryParse(inputState.join_numberController.text);
          final email = inputState.join_emailController.text;
          final password = inputState.join_pwController.text;
          final name = inputState.join_nameController.text;
          final major = inputState.join_majorController.text;
          final grade = int.tryParse(inputState.join_Grade ?? '');
          final gender = inputState.join_Gender ?? '';
          final residence = inputState.join_homeController.text;

          if (studentId == null || grade == null) {
            textmessageDialog(context, '학번과 학년은 숫자로 입력해주세요.');
            return;
          }

          try {
            final response = await AuthApi.register(
              studentId,
              email,
              password,
              name,
              major,
              grade,
              gender,
              residence,
            );
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (response.statusCode == 201) {
              finishJoinDialog(context); // 성공 메시지
            } else {
              final responseBody = json.decode(response.body);
              textmessageDialog(context, responseBody['message'] ?? '회원가입 실패');
            }
          } catch (error) {
            textmessageDialog(context, '회원가입 중 오류가 발생했습니다.');
            print('Registration error: $error');
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(width: 1.25),
        ),
        child: const Text(
          '회원가입',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
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
        //dialog 사이즈
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: 70,
          ),
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

void finishJoinDialog(BuildContext context) {
  final _JoinInputState? inputState = joinPWInputKey.currentState;
  if (inputState == null) return;

  final email = inputState.join_emailController.text;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        // dialog 사이즈
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: 120,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '회원가입 정보가 저장되었습니다. \n 마지막 설정인 캐릭터 선택을 해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog first
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharacterPage(email: email),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 1.2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  ),
                  child: const Text(
                    '캐릭터 선택',
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
