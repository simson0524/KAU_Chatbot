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
        print('Fetched inquiries: $data'); // 서버 응답 로그
        setState(() {
          posts = data.map<Map<String, String>>((item) {
            print('Processing item: $item'); // 각 항목 로그
            final dateTime = DateTime.parse(item['created_at']);
            final formattedDate =
                "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

            return {
              'id': item['inquiry_id'].toString(),
              'title': item['title'],
              'content': item['content'],
              'date': formattedDate,
              'department': item['department_name'],
            };
          }).toList();
          print('Processed posts: $posts'); // 매핑된 데이터 로그
          filteredPosts = posts;
        });
      } else {
        textmessageDialog(context, '문의 게시판 데이터를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      print('Error in fetchInquiries: $e');
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
          ),
        ),
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
  bool canComment = false; // 댓글 작성 권한 여부
  String? userStudentId; // 사용자 학번
  String boardAuthor = '익명'; // 게시글 작성자 초기값
  String boardContent = '내용 없음'; // 게시글 내용 초기값

  // 관리자로 설정된 학번 리스트
  final List<String> adminStudentIds = [
    '11111111',
    '2222222222',
    '3333333333',
    '4444444444',
    '5555555555',
    '6666666666'
  ];
  @override
  void initState() {
    super.initState();
    print('PostQnaDetailPage initState called.');

    print('Calling _fetchInquiryDetails...');
    _fetchInquiryDetails().then((_) {
      print('_fetchInquiryDetails completed.');
    }).catchError((error) {
      print('_fetchInquiryDetails error: $error');
    });

    print('Calling _checkUserPermission...');
    _checkUserPermission().then((_) {
      print('_checkUserPermission completed.');
    }).catchError((error) {
      print('_checkUserPermission error: $error');
    });
  }

  Future<void> _checkUserPermission() async {
    print('_checkUserPermission called.');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    print('AccessToken from SharedPreferences: $accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      print('_checkUserPermission: AccessToken is null or empty.');
      _showDialog('로그인이 필요합니다.');
      Navigator.pop(context);
      return;
    }

    try {
      final userInfo = await AuthApi.getUserInfo(accessToken);
      print('User Info: $userInfo');

      userStudentId = userInfo['student_id']?.toString();
      print('User Student ID: $userStudentId');

      setState(() {
        canComment = adminStudentIds.contains(userStudentId);
        print('Can Comment: $canComment');
      });
    } catch (error) {
      print('Error in _checkUserPermission: $error');
      _showDialog('사용자 정보를 불러오는데 실패했습니다.');
    }
  }

  Future<void> _fetchInquiryDetails() async {
    print('_fetchInquiryDetails called.');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    print('AccessToken from SharedPreferences: $accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      print('_fetchInquiryDetails: AccessToken is null or empty.');
      _showDialog('로그인이 필요합니다.');
      Navigator.pop(context);
      return;
    }

    final inquiryId = widget.post['id'];
    print('Inquiry ID: $inquiryId');

    if (inquiryId == null || inquiryId.isEmpty) {
      print('_fetchInquiryDetails: Inquiry ID is null or empty.');
      _showDialog('문의 ID가 유효하지 않습니다.');
      Navigator.pop(context);
      return;
    }

    try {
      print('Making API call to fetch inquiry details...');
      final response =
          await QnaBoardApi.getInquiryDetails(inquiryId, accessToken);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Decoded Response Data: $responseData');

        setState(() {
          boardAuthor = responseData['author_name'] ?? '익명';
          boardContent = responseData['content'] ?? '내용 없음';

          final commentsData = responseData['comments'] as List<dynamic>?;
          if (commentsData != null) {
            comments = commentsData.map<Map<String, String>>((comment) {
              print('Comment: $comment');
              return {
                'department_name': comment['department_name'] ?? '익명',
                'content': comment['content'] ?? '내용 없음',
                'created_at': comment['created_at']?.split('T')[0] ?? '날짜 없음',
              };
            }).toList();
          } else {
            print('No comments found in response.');
            comments = [];
          }
        });
      } else {
        print(
            '_fetchInquiryDetails: Failed with status ${response.statusCode}');
        _showDialog('문의 상세 데이터를 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (error) {
      print('_fetchInquiryDetails error: $error');
      _showDialog('네트워크 오류가 발생했습니다.');
    }
  }

  Future<void> addComment() async {
    if (!canComment) {
      _showDialog('관리자가 아닙니다.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      _showDialog('로그인이 필요합니다.');
      return;
    }

    if (commentController.text.isEmpty) {
      _showDialog('댓글 내용을 입력해주세요.');
      return;
    }

    try {
      final response = await QnaBoardApi.addComment(
          widget.post['id']!, commentController.text, accessToken);

      if (response.statusCode == 201) {
        _showDialog('댓글이 성공적으로 등록되었습니다.');
        _fetchInquiryDetails(); // 댓글 등록 후 갱신
        commentController.clear();
      } else {
        _showDialog('댓글 등록에 실패했습니다.');
      }
    } catch (error) {
      print('Error adding comment: $error');
      _showDialog('네트워크 오류가 발생했습니다.');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
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
                  // 제목 및 부서 표시
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      constraints: BoxConstraints(minHeight: 35.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post['title']!,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          if (widget.post['department'] != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: EdgeInsets.only(top: 4.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  widget.post['department']!,
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

                  // 내용 및 작성자 표시
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      constraints: BoxConstraints(minHeight: 50.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '작성자: $boardAuthor', // 동적으로 로드된 작성자 표시
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            boardContent, // 동적으로 로드된 게시글 내용 표시
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 댓글 표시
                  Text(
                    '답글',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '작성자: ${comment['department_name']}',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  comment['content']!,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    comment['created_at']!,
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

                  // 댓글 입력
                  if (canComment)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: '답글을 입력하세요',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            addComment();
                          },
                          child: Text('등록'),
                        ),
                      ],
                    ),
                  if (!canComment)
                    Text(
                      '댓글 작성 권한이 없습니다.',
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
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
