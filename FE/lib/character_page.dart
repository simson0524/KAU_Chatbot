import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/grid_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SingleChildScrollView(
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
                SizedBox(height: 70),
                Padding(
                  padding: EdgeInsets.only(left: 250.0),
                  child: Basic(),
                ),
                SizedBox(height: 100),
              ],
            ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChattingPage()),
        );
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChattingPage()),
        );
      },
      child: Container(
        width: 126,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChattingPage()),
        );
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

class Basic extends StatelessWidget {
  const Basic({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<CharacterProvider>(context, listen: false)
            .setCharacter('KAU 챗봇');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChattingPage()),
        );
      },
      child: Container(
        width: 100,
        height: 26,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/basic_image.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
