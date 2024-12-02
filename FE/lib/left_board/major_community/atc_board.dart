import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FE/api/auth_api.dart';
import 'package:FE/api/board_api.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: AtcBoardPage(),
  ));
}

// 게시판 화면
class AtcBoardPage extends StatefulWidget {
  @override
  _AtcBoardPageState createState() => _AtcBoardPageState();
}

const String fixMajorId = 'Atc'; // 고정된 학번

class _AtcBoardPageState extends State<AtcBoardPage> {
  List<Map<String, String>> posts = [];
  List<Map<String, String>> filteredPosts = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  // 제목과 내용 입력 필드 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<Map<String, String>> comments = []; // 댓글 데이터를 저장할 리스트
  String? accessToken; // 토큰을 저장할 변수
  String? userName; // 사용자 이름 저장

  @override
  void initState() {
    super.initState();
    loadAccessToken(); // 토큰 로드
    filteredPosts = posts;
    //fetchComments(); // 댓글 데이터 로드
  }

  Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken'); // 저장된 토큰 가져오기

    if (accessToken == null || accessToken!.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      // 사용자 정보 가져오기
      final userInfo = await AuthApi.getUserInfo(accessToken!);
      setState(() {
        userName = userInfo['name']; // 사용자 이름 설정
      });

      fetchPosts(); // 게시글 로드
    } catch (error) {
      textmessageDialog(context, '사용자 정보를 불러오는데 실패했습니다.');
      print('Error loading user info: $error');
    }
  }

  Future<void> fetchPosts() async {
    try {
      final response =
          await BoardApi.getMajorBoardList(fixMajorId, accessToken!);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('boards')) {
          final List<dynamic> boards = responseData['boards'];

          setState(() {
            posts = boards.map<Map<String, String>>((post) {
              // 날짜 포맷팅: 시간 부분 제거
              String rawDate = post['created_at'] ?? '날짜 없음';
              String formattedDate = rawDate.split('T').first; // T로 나누어 날짜만 추출

              return {
                'id': post['id']?.toString() ?? '0', // 게시글 ID 추가
                'title': post['title'] ?? '제목 없음',
                'content': post['content'] ?? '내용 없음',
                'date': formattedDate,
                'name': post['author']?.toString() ?? '작성자 없음',
              };
            }).toList();
            filteredPosts = posts;
          });
        } else {
          throw Exception('responseData에 boards 키가 없습니다.');
        }
      } else {
        textmessageDialog(context, '게시글 데이터를 불러오는데 실패했습니다.');
      }
    } catch (error) {
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
      print('Error fetching posts: $error');
    }
  }

  Future<void> addPost(String title, String content, String name) async {
    try {
      final response =
          await BoardApi.createMajorBoard('Atc', accessToken!, title, content);

      if (response.statusCode == 201) {
        textmessageDialog(context, '게시글이 성공적으로 등록되었습니다.');
        fetchPosts(); // 게시글 갱신
      } else {
        textmessageDialog(context, '게시글 등록에 실패했습니다.');
      }
    } catch (error) {
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
      print('Error adding post: $error');
    }
  }

  void filterPosts(String keyword) {
    setState(() {
      filteredPosts = posts
          .where((post) =>
              post['title']!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
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
        title: Text('항공교통물류학부 게시판', style: TextStyle(color: Colors.black)),
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
                              builder: (context) => PostAtcBoardDetailPage(
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
                      builder: (context) => NewAtcBoardPostPage(
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
class NewAtcBoardPostPage extends StatelessWidget {
  final Function(String, String, String) onAddPost;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  NewAtcBoardPostPage({required this.onAddPost});

  Future<void> submitPost(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      return;
    }

    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      textmessageDialog(context, '제목과 내용을 모두 입력해주세요.');
      return;
    }

    try {
      // 작성자 이름 가져오기
      final userInfo = await AuthApi.getUserInfo(accessToken);
      final userName = userInfo['name'] ?? '알 수 없음';

      // API를 통해 게시글 등록
      final response = await BoardApi.createMajorBoard(
        'Atc', // 학번을 고정값으로 사용
        accessToken,
        titleController.text,
        contentController.text,
      );

      if (response.statusCode == 201) {
        textmessageDialog(context, '게시글이 성공적으로 등록되었습니다.');

        // 1초 딜레이 후 AtcBoard게시판으로 이동
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AtcBoardPage(),
            ),
          );
        });
      } else {
        final responseBody = json.decode(response.body);
        textmessageDialog(
            context, responseBody['message'] ?? '게시글 등록에 실패했습니다.');
      }
    } catch (error) {
      print('Error during post submission: $error');
      textmessageDialog(context, '게시글 등록 중 오류가 발생했습니다.');
    }
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
        title: Text('항공교통물류학부 게시판', style: TextStyle(color: Colors.black)),
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
                  SizedBox(height: 16),

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
                          // 작성자 이름 표시 부분
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: SharedPreferences.getInstance().then(
                                (prefs) => AuthApi.getUserInfo(
                                    prefs.getString('accessToken') ?? ''),
                              ),
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
                                      snapshot.data?['name'] ?? '알 수 없음';
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
                        onTap: () => submitPost(context),
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
class PostAtcBoardDetailPage extends StatefulWidget {
  final Map<String, String> post;

  PostAtcBoardDetailPage({required this.post});

  @override
  _PostAtcBoardDetailPageState createState() => _PostAtcBoardDetailPageState();
}

class _PostAtcBoardDetailPageState extends State<PostAtcBoardDetailPage> {
  List<Map<String, dynamic>> comments = [];
  TextEditingController commentController = TextEditingController();
  bool isLoading = true; // 로딩 상태 표시
  String? authorName; // 작성자 이름

  @override
  void initState() {
    super.initState();
    fetchPostDetails();
  }

  Future<void> fetchPostDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      Navigator.pop(context);
      return;
    }

    final postId = int.tryParse(widget.post['id'] ?? '');
    if (postId == null) {
      print('Invalid Post ID: ${widget.post['id']}');
      textmessageDialog(context, '잘못된 게시글 ID입니다.');
      Navigator.pop(context);
      return;
    }

    print('Fetching details for Post ID: $postId');

    try {
      final response =
          await BoardApi.getMajorBoardDetail('Atc', postId, accessToken);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('board')) {
          final boardData = responseData['board'];

          // 날짜만 추출
          final createdDate = (boardData['created_at'] ?? '').split('T').first;

          setState(() {
            authorName = boardData['author_name'] ?? '작성자 없음';
            widget.post['content'] = boardData['content'] ?? '내용 없음';
            widget.post['created_at'] = createdDate; // 날짜만 저장
            comments = responseData['comments'] != null
                ? List<Map<String, dynamic>>.from(responseData['comments'])
                : [];
            isLoading = false;

            // 상태값 출력
            print('Author Name: $authorName');
            print('Content: ${widget.post['content']}');
            print('Created At: $createdDate');
            print('Comments: $comments');
          });
        } else {
          textmessageDialog(context, '게시글 데이터를 불러오는데 실패했습니다.');
        }
      } else {
        textmessageDialog(context, '게시글 데이터를 불러오는데 실패했습니다.');
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error fetching post details: $error');
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
      Navigator.pop(context);
    }
  }

  Future<void> submitComment() async {
    print('Attempting to submit comment...');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    // Access Token 확인 로그
    print('Access Token: $accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      textmessageDialog(context, '로그인이 필요합니다.');
      return;
    }

    if (commentController.text.isEmpty) {
      textmessageDialog(context, '댓글 내용을 입력해주세요.');
      return;
    }

    // Post ID 확인 로그
    final postId = int.tryParse(widget.post['id'] ?? '');
    if (postId == null) {
      print('Invalid Post ID: ${widget.post['id']}');
      textmessageDialog(context, '잘못된 게시글 ID입니다.');
      return;
    }

    print('Submitting comment for Post ID: $postId');

    try {
      final response = await BoardApi.addCommentMajor(
        'Atc',
        postId,
        accessToken,
        commentController.text,
      );

      // API 응답 로그
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        textmessageDialog(context, '댓글이 성공적으로 등록되었습니다.');
        fetchPostDetails(); // 댓글 등록 후 게시글 갱신
        commentController.clear();
      } else {
        final responseData = json.decode(response.body);
        print('Error Response: $responseData');
        textmessageDialog(context, responseData['message'] ?? '댓글 등록에 실패했습니다.');
      }
    } catch (error) {
      print('Error submitting comment: $error');
      textmessageDialog(context, '네트워크 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('항공교통물류학부 게시판', style: TextStyle(color: Colors.black)),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        widget.post['title']!,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
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
                                '작성자: $authorName', // 임시로 표시할 작성자 이름
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
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 15.0, right: 85.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final authorName = comment['author_name'] ?? '익명';
                        final content = comment['content'] ?? '내용 없음';
                        final createdAt = (comment['created_at'] ?? '')
                            .split('T')
                            .first; // 날짜만 표시

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15.0), // 패딩 추가
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 내용
                                    Text(
                                      content,
                                      style: TextStyle(
                                        fontSize: 16.0, // 폰트 크기 증가
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // 작성자 이름
                                    Text(
                                      '작성자: $authorName',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -65.0,
                                bottom: 0.0,
                                child: Text(
                                  createdAt,
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
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '답글을 입력하세요',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.subdirectory_arrow_left),
                                onPressed: submitComment,
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
