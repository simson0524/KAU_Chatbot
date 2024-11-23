import 'package:FE/character_provider.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FE/api/auth_api.dart'; // API 호출 함수 추가

class CharacterPage extends StatelessWidget {
  final String email;

  const CharacterPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const CharacterImage(),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Mile(email: email), // const 제거
                          const SizedBox(width: 10),
                          Maha(email: email), // const 제거
                          const SizedBox(width: 10),
                          Feet(email: email), // const 제거
                        ],
                      ),
                    ],
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

class CharacterImage extends StatelessWidget {
  const CharacterImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 76, right: 16, left: 16),
          child: Center(
            child: Image.asset('assets/images/chatbot_login.png'),
          ),
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Text(
            '안녕하세요. \n KAU CHATBOT입니다. \n 대화하고 싶은 상대를 선택해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class Mile extends StatelessWidget {
  final String email;

  const Mile({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectCharacter(context, 'mile', email); // 이메일 전달
      },
      child: Container(
        width: 85,
        height: 181,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/character_mile.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Maha extends StatelessWidget {
  final String email;

  const Maha({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectCharacter(context, 'maha', email); // 이메일 전달
      },
      child: Container(
        width: 130,
        height: 189,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/character_maha.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Feet extends StatelessWidget {
  final String email;

  const Feet({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectCharacter(context, 'feet', email); // 이메일 전달
      },
      child: Container(
        width: 85,
        height: 131,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/character_feet.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

//회원가입 모두 완료 알림창
void finishallJoinDialog(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '회원가입이 모두 완료되었습니다. \n 재로그인해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10), //텍스트와 버튼 사이 간격
                //캐릭터선택 버튼
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

void _selectCharacter(
    BuildContext context, String character, String email) async {
  try {
    final response = await AuthApi.setChatCharacter(email, character); // API 호출
    if (response.statusCode == 200) {
      finishallJoinDialog(context); // 성공 메시지 다이얼로그
    } else {
      _showErrorDialog(context, '캐릭터 설정에 실패했습니다. 다시 시도해주세요.');
    }
  } catch (error) {
    _showErrorDialog(context, '오류가 발생했습니다: $error');
  }
}

// 오류 메시지 다이얼로그
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}
