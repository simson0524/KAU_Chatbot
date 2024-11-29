import 'package:FE/chatting_page.dart';
import 'package:FE/main.dart';
import 'package:flutter/material.dart';
import 'package:FE/api/auth_api.dart'; // API 추가
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemberInfo extends StatefulWidget {
  const MemberInfo({super.key});

  @override
  State<MemberInfo> createState() => _MemberInfoState();
}

class _MemberInfoState extends State<MemberInfo> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController homeController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  String? gender;
  String? grade;
  late String accessToken;
  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch user info on init
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken") ?? ''; // Token 가져오기

    if (accessToken.isEmpty) {
      _showErrorDialog('로그인 정보가 없습니다. 다시 로그인해주세요.');
      return;
    }

    try {
      final userInfo = await AuthApi.getUserInfo(accessToken); // API 호출

      setState(() {
        numberController.text = userInfo['student_id'].toString();
        nameController.text = userInfo['name'];
        emailController.text = userInfo['email'];
        homeController.text = userInfo['residence'];
        majorController.text = userInfo['major'];
        gender = userInfo['gender'];
        grade = userInfo['grade'].toString();
        // chat_character 처리 필요 시 추가
      });
    } catch (error) {
      print('Error fetching user info: $error');
      _showErrorDialog('사용자 정보를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _updateUserInfo() async {
    if (accessToken.isEmpty) {
      _showErrorDialog('로그인 정보가 없습니다. 다시 로그인해주세요.');
      return;
    }

    try {
      final response = await AuthApi.updateUserInfo(
        name: nameController.text.trim(),
        major: majorController.text.trim(),
        grade: int.parse(grade ?? '0'),
        residence: homeController.text.trim(),
        chatCharacter: 'default_character', // 필요 시 사용자 선택 값으로 대체
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('개인정보 수정이 완료되었습니다.');
      } else {
        _showErrorDialog('개인정보 수정에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      print('Error updating user info: $error');
      _showErrorDialog('개인정보 수정 중 오류가 발생했습니다.');
    }
  }

  Future<void> deleteUser() async {
    try {
      final response = await AuthApi.deleteUser(accessToken);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("accessToken"); // Remove token on success
        _showSuccessDialog('회원 탈퇴가 완료되었습니다.');

        // 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage()), // LoginPage로 직접 이동
        );
      } else {
        _showErrorDialog('회원 탈퇴 실패: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting user: $error');
      _showErrorDialog('다시 시도해주세요.');
    }
  }

  void finish_member_info_Dialog(String dialogMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close the dialog
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
                      dialogMessage,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성공'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '개인 정보 수정',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 돌아가기
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
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
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 학번 입력 필드
                              Expanded(
                                child: TextFormField(
                                  controller: numberController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: '학번',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // 이름 입력 필드
                              Expanded(
                                child: TextFormField(
                                  controller: nameController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: '이름',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 이메일 입력 필드
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            controller: emailController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true, // 수정 불가
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: homeController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: '거주지',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: gender,
                                  decoration: const InputDecoration(
                                    labelText: '성별',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ['남', '여'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      gender = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: majorController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: '전공',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: grade,
                                  decoration: const InputDecoration(
                                    labelText: '학년',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ['1', '2', '3', '4', '기타']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      grade = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () async {
                            await _updateUserInfo(); // Update user info via API
                            //finish_member_info_Dialog(
                            //    '개인정보 수정이 완료되었습니다.'); // Show the dialog
                          },
                          child: const Text(
                            '수정 완료',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 회원탈퇴 버튼 위치
          Positioned(
            bottom: 80.0,
            right: 15.0,
            child: TextButton(
              onPressed: () {
                show_withdrawal_Dialog(
                    context, deleteUser); // Pass the deleteUser function
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
                side: const BorderSide(color: Colors.black),
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

// 이미지 위젯
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

void show_withdrawal_Dialog(
    BuildContext context, Future<void> Function() onDeleteUser) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close dialog
                          await onDeleteUser(); // Call the delete function
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
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
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
