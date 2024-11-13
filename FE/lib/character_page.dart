import 'package:FE/character_provider.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key});

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
                child: const SingleChildScrollView(
                  child: Column(
                    children: [
                      CharacterImage(),
                      SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 200, child: Mile()),
                          SizedBox(width: 10),
                          SizedBox(height: 200, child: Maha()),
                          SizedBox(width: 10),
                          SizedBox(height: 131, child: Feet())
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
  const Mile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<CharacterProvider>(context, listen: false)
            .setCharacter('마일');
        finishallJoinDialog(context);
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
  const Maha({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<CharacterProvider>(context, listen: false)
            .setCharacter('마하');
        finishallJoinDialog(context);
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
  const Feet({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<CharacterProvider>(context, listen: false)
            .setCharacter('피트');
        finishallJoinDialog(context);
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
