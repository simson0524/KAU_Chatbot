import 'package:FE/chatting_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Board19Page(),
  ));
}

// 게시판 화면
class Board19Page extends StatefulWidget {
  @override
  _Board19PageState createState() => _Board19PageState();
}

class _Board19PageState extends State<Board19Page> {
  List<Map<String, String>> posts = [];
  List<Map<String, String>> filteredPosts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPosts = posts;
  }

  void addPost(String title, String content) {
    setState(() {
      posts.add({
        'title': title,
        'content': content,
        'date': DateTime.now().toString().split(' ')[0]
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
        title: Text('19학번 게시판', style: TextStyle(color: Colors.black)),
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
                              builder: (context) => Post19DetailPage(
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
                      builder: (context) => New19PostPage(
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
class New19PostPage extends StatelessWidget {
  final Function(String, String) onAddPost;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  New19PostPage({required this.onAddPost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('19학번 게시판', style: TextStyle(color: Colors.black)),
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
                      child: SingleChildScrollView(
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
                    ),
                  ),
                  SizedBox(height: 20),
                  // 등록 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          onAddPost(
                              titleController.text, contentController.text);
                          Navigator.pop(context);
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
class Post19DetailPage extends StatefulWidget {
  final Map<String, String> post;

  Post19DetailPage({required this.post});

  @override
  _Post19DetailPageState createState() => _Post19DetailPageState();
}

class _Post19DetailPageState extends State<Post19DetailPage> {
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
        title: Text('19학번 게시판', style: TextStyle(color: Colors.black)),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.post['content']!,
                          style: TextStyle(fontSize: 16.0),
                        ),
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
                                onPressed: () {
                                  addComment(commentController.text);
                                },
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
