import 'package:FE/chatting_page.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';

class MemberInfo extends StatelessWidget {
  const MemberInfo({super.key});

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
            Navigator.pop(context); // 이전 페이지로 돌아가기
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
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
                        const member_info_Image(),
                        const SizedBox(height: 0),
                        Stack(
                            //회원가입창 42줄부터 내용 추가
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          //회원탈퇴 버튼 위치
          Positioned(
            bottom: 80.0,
            right: 15.0,
            child: TextButton(
              onPressed: () {
                show_withdrawal_Dialog(context);
              }, // 버튼 동작
              style: TextButton.styleFrom(
                visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
                side: BorderSide(color: Colors.black),
              ),
              child: const Text(
                '회원탈퇴',
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//이미지
class member_info_Image extends StatelessWidget {
  const member_info_Image({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.only(top: 0),
      child: Center(
        child: Image.asset('assets/images/character_friend.png'),
      ),
    );
  }
}

//호출시
//finish_member_info_Dialog(context, '개인정보 수정이 완료되었습니다')

/*
//개인정보수정 완료 알림
void finish_member_info_Dialog(BuildContext context, String dialogmessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 5), () {
        if (Navigator.canPop(context)) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChattingPage()),
          );
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
*/

//회원탈퇴 버튼 클릭시 호출
void show_withdrawal_Dialog(BuildContext context) {
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
            padding: const EdgeInsets.only(bottom: 3.0, top: 5.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '회원탈퇴를 하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  //회원탈퇴 - 네
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
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
                            '네',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      //회원탈퇴 - 아니요
                      Padding(
                        padding: const EdgeInsets.only(right: 1.0),
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
                            '아니요',
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
