import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FE/api/qna_board_api.dart'; // QnaBoardApi 임포트
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:FE/api/auth_api.dart';

void main() {
  runApp(MaterialApp(
    home: QnaBoardPage(),
  ));
}

class QnaBoardPage extends StatefulWidget {
  @override
  _QnaBoardPageState createState() => _QnaBoardPageState();
}

// 게시판 화면
class _QnaBoardPageState extends State<QnaBoardPage> {
  List<Map<String, String>> posts = [];
  List<Map<String, String>> filteredPosts = [];
  String? accessToken;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAccessToken();
  }

  // SharedPreferences에서 AccessToken 로드
  Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken!.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    fetchInquiries(); // 토큰 로드 후 게시글 가져오기
  }

  Future<void> fetchInquiries() async {
    if (accessToken == null) return;

    try {
      final response = await QnaBoardApi.getInquiries(accessToken!);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map<Map<String, String>>((item) {
            // 날짜 포맷팅
            final dateTime = DateTime.parse(item['created_at']);
            final formattedDate =
                "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
            return {
              'title': item['title'],
              'content': item['content'],
              'date': formattedDate, // 포맷된 날짜만 저장
              'department': item['department_name'],
            };
          }).toList();
          filteredPosts = posts;
        });
      } else {
        textmessageDialog(context, '문의 게시판 데이터를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
    }
  }

  void addPost(String title, String content, String name, String department) {
    setState(() {
      posts.add({
        'title': title,
        'content': content,
        'date': DateTime.now().toString().split(' ')[0],
        'name': name,
        'department': department,
      });
      filteredPosts = posts;
    });
  }

  void filterPosts(String keyword) {
    setState(() {
      filteredPosts =
          posts.where((post) => post['title']!.contains(keyword)).toList();
    });
  }

  void resetFilter() {
    setState(() {
      filteredPosts = posts;
    });
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('학교문의 게시판', style: TextStyle(color: Colors.black)),
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 15.0, right: 85.0), //전체 여백
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostQnaDetailPage(
                                post: filteredPosts[index], // 클릭된 게시물의 데이터 전달
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              //제목 박스
                              Container(
                                padding:
                                    const EdgeInsets.all(10.0), // 제목 박스 안의 여백
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        filteredPosts[index]['title']!,
                                        style: TextStyle(fontSize: 16.0),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 부서 표시
                              Positioned(
                                right: 10.0,
                                bottom: 10.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    filteredPosts[index]
                                        ['department']!, // 부서 표시
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.black54),
                                  ),
                                ),
                              ),

                              Positioned(
                                right: -65.0,
                                bottom: 0.0,
                                child: Text(
                                  filteredPosts[index]['date']!,
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          //검색어 입력 부분
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '검색어 입력',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          filterPosts(searchController.text);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          //글 등록 버튼
          Positioned(
            top: kToolbarHeight - 40.0,
            right: 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.black),
              ),
              padding:
                  EdgeInsets.only(right: 1.0, left: 1.0, top: 1.0, bottom: 1.0),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewQnaPostPage(
                        onAddPost: addPost,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 글 등록 페이지
class NewQnaPostPage extends StatelessWidget {
  final Function(String, String, String, String) onAddPost;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? selectedDepartment; //초기값 null 설정

  NewQnaPostPage({required this.onAddPost});

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> submitPost(BuildContext context) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('AccessToken 없음');
      textmessageDialog(context, '로그인이 필요합니다.');
      return;
    }

    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        selectedDepartment == null) {
      textmessageDialog(context, '제목, 내용 및 문의 부서를 모두 입력해주세요.');
      return;
    }

    try {
      // JSON에서 사용자명 추출

      final departmentMapping = {
        '교무처': 1,
        '학생처': 2,
        '기획처': 3,
        '연구협력처': 4,
        '국제교류처': 5,
        '사무처': 6
      };
      final departmentId = departmentMapping[selectedDepartment!];

      print('API 호출 시작');
      final response = await QnaBoardApi.createInquiry(
        titleController.text,
        contentController.text,
        departmentId!,
        accessToken,
      );

      if (response.statusCode == 201) {
        textmessageDialog(context, '문의가 성공적으로 등록되었습니다.');

        // QnaBoardPage로 이동
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => QnaBoardPage()),
            (route) => false,
          );
        });
      } else {
        textmessageDialog(
            context, '문의 등록에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('학교문의 게시판', style: TextStyle(color: Colors.black)),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // 제목 입력 칸
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '제목',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // 문의부서 선택 부분 추가
                  Container(
                    margin: EdgeInsets.only(bottom: 16.0), // 아래 여백 추가
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // '문의부서' 텍스트 박스
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            '문의부서',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        // 부서 선택 드롭다운
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.4, // 절반 크기로 조정
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: selectedDepartment,
                            isExpanded: true,
                            hint: Text('선택'),
                            items: [
                              '교무처',
                              '학생처',
                              '기획처',
                              '연구협력처',
                              '국제교류처',
                              '사무처',
                            ].map((String department) {
                              return DropdownMenuItem<String>(
                                value: department,
                                child: Text(department),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                selectedDepartment = newValue;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2),

                  // 내용 입력 칸
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: TextField(
                              controller: contentController,
                              maxLines: null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: '내용',
                              ),
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: _getAccessToken().then((token) =>
                                  AuthApi.getUserInfo(token!)), // 사용자 정보 API 호출
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    '작성자: 로딩 중...',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    '작성자: 오류 발생',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.red,
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final userName =
                                      snapshot.data!['name'] ?? '알 수 없음';
                                  return Text(
                                    '작성자: $userName',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    '작성자: 정보 없음',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  // 등록 버튼

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (titleController.text.isEmpty ||
                              contentController.text.isEmpty ||
                              selectedDepartment == null) {
                            textmessageDialog(
                                context, '제목과 내용 및 문의 부서를 모두 입력해주세요.');
                            return;
                          }

                          await submitPost(context); // 서버로 데이터 전송 및 처리
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.black),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('등록'),
                              Icon(Icons.subdirectory_arrow_left,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 글 상세 페이지
class PostQnaDetailPage extends StatefulWidget {
  final Map<String, String> post;

  PostQnaDetailPage({required this.post});

  @override
  _PostQnaDetailPageState createState() => _PostQnaDetailPageState();
}

class _PostQnaDetailPageState extends State<PostQnaDetailPage> {
  List<Map<String, String>> comments = [];
  TextEditingController commentController = TextEditingController();

  void addComment(String comment) {
    setState(() {
      comments.add({
        'comment': comment,
        'date': DateTime.now().toString().split(' ')[0],
      });
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('학교문의 게시판', style: TextStyle(color: Colors.black)),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //제목 표시
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 35.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Stack(
                        children: [
                          Text(
                            widget.post['title']!,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          // 부서 표시 코드 추가
                          Positioned(
                            right: 0,
                            top: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                ' ${widget.post['department']}', // 부서 표시
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 내용 표시
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 50.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Text(
                              widget.post['content']!,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                '작성자: ${widget.post['name']}', // 임시로 표시할 작성자 이름
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 댓글 표시
                  Text('답글',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 15.0, right: 85.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        comments[index]['comment']!,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -65.0,
                                bottom: 0.0,
                                child: Text(
                                  comments[index]['date']!,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  //댓글 달기 권한 부여 필요
                  //댓글 달기
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: commentController,
                            //여기에 권한 여부에따라 활성화 비활성화 코드 작성
                            //ex, 권한 체크 변수를 bool canComment라고 하면 enabled: canComment, 코드 추가 ( ture일때만 작성가능하게)
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '답글을 입력하세요',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.subdirectory_arrow_left),
                                onPressed:
                                    //위처럼 권한 체크시 이 부분에 canComment ? 추가
                                    () {
                                  addComment(commentController.text);
                                },
                                //위처럼 권한 체크 시 이 부분에 : null , 추가하여 권한 없을 시 동작하지 않게
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//텍스트 다이얼로그알림
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
