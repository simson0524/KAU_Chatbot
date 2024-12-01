import 'package:FE/character_provider.dart';
import 'package:FE/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:FE/api/notice_board_api.dart'; // API 호출을 위한 파일
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    home: ExternalBoardPage(),
  ));
}

// 게시판 화면
class ExternalBoardPage extends StatefulWidget {
  @override
  _ExternalBoardPageState createState() => _ExternalBoardPageState();
}

class _ExternalBoardPageState extends State<ExternalBoardPage> {
  List<Map<String, String>> posts = [];
  List<Map<String, String>> filteredPosts = [];
  TextEditingController searchController = TextEditingController();
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadExternals();
  }

  Future<void> _loadExternals() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken!.isEmpty) {
      print("[DEBUG] Access token is missing or empty.");
      _showDialog('로그인이 필요합니다.');
      return;
    }

    try {
      print("[DEBUG] Fetching school notices with access token: $accessToken");
      final notices = await NoticeBoardApi.getExternalNotices(accessToken!);

      print("[DEBUG] Externals fetched successfully: $notices");

      setState(() {
        posts = notices.map((notice) {
          try {
            // 날짜만 추출
            String dDay = notice['dDay']?.toString() ?? 'N/A';

            return {
              'idx': notice['idx'].toString(),
              'title': notice['title'].toString(),
              'date': dDay, // 변환된 날짜 사용
            };
          } catch (e) {
            print("[ERROR] Error while parsing notice: $notice, Error: $e");
            return {
              'idx': 'N/A',
              'title': 'Invalid Data',
              'date': 'N/A',
            };
          }
        }).toList();

        filteredPosts = posts;
        print("[DEBUG] Posts updated successfully.");
      });
    } catch (e) {
      print("[ERROR] Failed to fetch school notices. Error: $e");
      _showDialog('공지사항을 불러오는 데 실패했습니다.');
    }
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

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
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
        elevation: 0.0,
        title: Text('외부공지 게시판', style: TextStyle(color: Colors.black)),
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
                              builder: (context) => ExternalPostDetailPage(
                                idx: filteredPosts[index]['idx']!, // idx 전달
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
        ],
      ),
    );
  }
}

// 글 상세 페이지
class ExternalPostDetailPage extends StatefulWidget {
  final String idx;

  ExternalPostDetailPage({required this.idx});

  @override
  _ExternalPostDetailPageState createState() => _ExternalPostDetailPageState();
}

class _ExternalPostDetailPageState extends State<ExternalPostDetailPage> {
  Map<String, String>? postDetail;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadExternalDetail();
  }

  Future<void> _loadExternalDetail() async {
    print("[DEBUG] Starting _loadExternalDetail");
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken!.isEmpty) {
      print("[DEBUG] Access token is missing or empty.");
      _showDialog('로그인이 필요합니다.');
      return;
    }

    try {
      print(
          "[DEBUG] Fetching notice detail for idx: ${widget.idx} with access token: $accessToken");
      final detail = await NoticeBoardApi.getExternalNoticeDetail(
          widget.idx, accessToken!);

      print("[DEBUG] External detail fetched successfully: $detail");

      if (detail.isNotEmpty) {
        setState(() {
          postDetail = {
            'title': detail['title'] ?? '제목 없음',
            'text': detail['text'] ?? '내용 없음',
            'date': detail['dDay'] ?? '날짜 없음',
            'url': detail['url'] ?? '', // URL 추가
          };
        });
        print("[DEBUG] Post detail updated successfully: $postDetail");
      } else {
        print("[ERROR] External detail is empty.");
        _showDialog('공지사항을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print("[ERROR] Failed to fetch notice detail. Error: $e");
      _showDialog('공지사항을 불러오는 데 실패했습니다.');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    print("[DEBUG] Attempting to launch URL: $url");

    try {
      if (await canLaunchUrl(uri)) {
        print("[DEBUG] URL can be launched: $url");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("[ERROR] Cannot launch URL: $url");
        _showDialog('URL을 열 수 없습니다: $url');
      }
    } catch (e) {
      print("[ERROR] Exception while launching URL: $e");
      _showDialog('URL을 여는 중 오류가 발생했습니다: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('공지사항 상세', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: postDetail == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(postDetail!['title']!,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),

                  // 날짜
                  Text(postDetail!['date']!,
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16.0),

                  // 내용
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        postDetail!['text']!,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // URL 버튼
                  if (postDetail!['url'] != null &&
                      postDetail!['url']!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _launchUrl(postDetail!['url']!),
                      child: Text(
                        '관련 링크 보기',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
