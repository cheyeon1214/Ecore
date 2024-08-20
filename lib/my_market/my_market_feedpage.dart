import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMarketFeedpage extends StatefulWidget {
  const MyMarketFeedpage({super.key});

  @override
  _MyMarketFeedpageState createState() => _MyMarketFeedpageState();
}

class _MyMarketFeedpageState extends State<MyMarketFeedpage> {
  List<String> _feedPosts = [];

  void _showAddPostDialog({int? index}) {
    final TextEditingController _postController = TextEditingController(
      text: index != null ? _feedPosts[index] : '', // 기존 텍스트를 불러오도록 설정
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            index == null ? '공지사항 입력' : '공지사항 수정',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _postController,
            decoration: InputDecoration(
              hintText: '공지사항 입력',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (index == null) {
                    _feedPosts.add(_postController.text);
                  } else {
                    _feedPosts[index] = _postController.text;
                  }
                });
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check),
              label: Text(index == null ? '추가' : '수정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(int index) {
    setState(() {
      _feedPosts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined),
                SizedBox(width: 8),
                Text('커뮤니티 | 공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _showAddPostDialog,
                ),
              ],
            ),
            SizedBox(height: 8),
            // 판매자 정보 박스
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('판매자 정보 확인', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _infoRow('대표자명', '윤지원'),
                  _infoRow('상호명', '에코리'),
                  _infoRow('문의전화', '010-0000-0000'),
                  _infoRow('사업자주소', '경기도 수원시 영통구 광교산로 154-42'),
                  SizedBox(height: 8),
                  Text('위 주소는 사업자등록증에 표기된 정보입니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 8),
                  _infoRow('사업자등록번호', '261-18-01763 호'),
                ],
              ),
            ),
            SizedBox(height: 16), // 파란 네모와 공지사항 리스트 사이 간격
            // 공지사항 리스트
            ..._feedPosts.asMap().entries.map((entry) {
              int index = entry.key;
              String post = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity, // 부모 위젯의 가로 길이를 채우도록 설정
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(post, style: TextStyle(fontSize: 16)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddPostDialog(index: index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePost(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          '$title  ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800], // 글씨색을 회색으로 설정
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.black), // 값은 검정색으로 설정
          ),
        ),
      ],
    );
  }
}
