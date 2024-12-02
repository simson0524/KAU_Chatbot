import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:FE/left_board/college_num_community/board_19.dart';
import 'package:FE/left_board/college_num_community/board_20.dart';
import 'package:FE/left_board/college_num_community/board_21.dart';
import 'package:FE/left_board/college_num_community/board_22.dart';
import 'package:FE/left_board/college_num_community/board_23.dart';
import 'package:FE/left_board/college_num_community/board_24.dart';
import 'package:FE/left_board/college_num_community/board_etc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollegeNum extends StatelessWidget {
  final List<String> departments = [
    '24학번', //페이지이름: board_24
    '23학번',
    '22학번',
    '21학번',
    '20학번',
    '19학번',
    '18학번 이전', //board_etc
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
          ),
        ),
        elevation: 0.0,
        title: Text('학과별 게시판', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChattingPage(),
                ),
              );
            },
          ),
        ],
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
          Container(
            color: Colors.white,
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/grid_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      title: Text(
                        departments[index],
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          // 학번별 페이지로 이동  코드
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                switch (departments[index]) {
                                  case '24학번':
                                    return Board24Page();
                                  case '23학번':
                                    return Board23Page();
                                  case '22학번':
                                    return Board22Page();
                                  case '21학번':
                                    return Board21Page();
                                  case '20학번':
                                    return Board20Page();
                                  case '19학번':
                                    return Board19Page();
                                  case '18학번 이전':
                                    return Board18Page();
                                  default:
                                    return Scaffold(
                                      body: Center(
                                        child: Text('페이지가 준비 중입니다.'),
                                      ),
                                    );
                                }
                              },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.black),
                          ),
                          padding: EdgeInsets.only(
                              right: 10.0, left: 10.0, top: 3.0, bottom: 3.0),
                          child: Icon(Icons.subdirectory_arrow_left,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
