import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:FE/left_board/major_community/ai_board.dart';
import 'package:FE/left_board/major_community/airbusiness_board.dart';
import 'package:FE/left_board/major_community/airelectronic_board.dart';
import 'package:FE/left_board/major_community/atc_board.dart';
import 'package:FE/left_board/major_community/aviation_board.dart';
import 'package:FE/left_board/major_community/business_board.dart';
import 'package:FE/left_board/major_community/computer_board.dart';
import 'package:FE/left_board/major_community/electronic_board.dart';
import 'package:FE/left_board/major_community/engineering_board.dart';
import 'package:FE/left_board/major_community/international_board.dart';
import 'package:FE/left_board/major_community/material_board.dart';
import 'package:FE/left_board/major_community/smartdrone_board.dart';
import 'package:FE/left_board/major_community/software_board.dart';
import 'package:FE/left_board/major_community/space_board.dart';
import 'package:FE/left_board/major_community/undeclared_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MajorBoard extends StatelessWidget {
  final List<String> departments = [
    '소프트웨어학과', //페이지이름: software_board
    '항공운항학과', //aviaition_board
    '항공교통물류학부', //atc_board
    '항공경영학과', //airbusiness_board
    '경영학과', //business_board
    '항공우주공학과' //space_board
        '기계항공공학과', //engineering_board
    '신소재공학과', //material_board
    '항공우주기계공학과', //spaceengineering_board
    '항공전자정보공학부', //airelectronic_board
    '스마트드론공학과', //smartdrone_board
    '전기전자공학과', //electronic_board
    '컴퓨터공학과', //computer_board
    'AI자율주행시스템공학과', //ai_board
    '자유전공학부', //undeclared_board
    '국제교류학부', //international_board
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                          // 학과별 페이지로 이동하는 Navigator 코드
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                switch (departments[index]) {
                                  case '소프트웨어학과':
                                    return SoftwareBoardPage();
                                  case '항공운항학과':
                                    return AvitationBoardPage();
                                  case '항공교통물류학부':
                                    return AtcBoardPage();
                                  case '항공경영학과':
                                    return AirbusinessBoardPage();
                                  case '경영학과':
                                    return BusinessBoardPage();
                                  case '항공우주공학과':
                                    return SpaceBoardPage();
                                  case '기계항공공학과':
                                    return EngineeringBoardPage();
                                  case '신소재공학과':
                                    return MaterialBoardPage();
                                  case '항공우주기계공학과':
                                    return SpaceBoardPage();
                                  case '항공전자정보공학부':
                                    return AirelectronicBoardPage();
                                  case '스마트드론공학과':
                                    return SmartdroneBoardPage();
                                  case '전지전자공학과':
                                    return ElectronicBoardPage();
                                  case '컴퓨터공학과':
                                    return ComputerBoardPage();
                                  case 'AI자율주행시스템공학과':
                                    return AiBoardPage();
                                  case '자유전공학부':
                                    return UndeclaredBoardPage();
                                  case '국제교류학부':
                                    return InternationalBoardPage();

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
