import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';

class SearchPage extends StatefulWidget {
  final String marketId;

  const SearchPage({Key? key, required this.marketId}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';  // 검색어를 저장할 변수
  bool showResults = false; // 검색 결과를 보여줄지 결정하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 버튼 클릭 시 이전 페이지로 돌아감
          },
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200], // 배경색 설정 (연한 회색)
            borderRadius: BorderRadius.circular(30), // 테두리 둥글게
          ),
          child: TextField(
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none, // 기본 테두리 제거
              hintText: '검색어를 입력해주세요', // 힌트 텍스트
              hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상 설정
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () {
              if (searchQuery.isNotEmpty) {
                // 검색어가 입력된 경우에만 검색 결과를 보여줌
                setState(() {
                  showResults = true; // 검색 결과를 보여줌
                });
              }
            },
          ),
        ],
      ),
      body: showResults
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('SellPosts')
            .where('marketId', isEqualTo: widget.marketId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('상품이 없습니다.'));
          }

          // 검색어를 포함하는 상품 필터링
          var filteredPosts = snapshot.data!.docs.where((doc) {
            var title = (doc['title'] as String).toLowerCase();
            return title.contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredPosts.isEmpty) {
            return Center(child: Text('검색 결과가 없습니다.'));
          }

          // 그리드 형태로 검색 결과 출력
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,  // 한 줄에 2개씩
              crossAxisSpacing: 8.0,  // 그리드 아이템 간격 (가로)
              mainAxisSpacing: 8.0,   // 그리드 아이템 간격 (세로)
              childAspectRatio: 0.6,  // 그리드 아이템 비율 (이미지 + 텍스트)
            ),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              var sellPost = SellPostModel.fromSnapshot(filteredPosts[index]);

              return GestureDetector(
                onTap: () {
                  // 상세 페이지로 이동하는 로직 추가
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 부분
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),  // 모서리를 둥글게
                      child: AspectRatio(
                        aspectRatio: 1.0,  // 1:1 비율로 고정
                        child: sellPost.img.isNotEmpty
                            ? Image.network(
                          sellPost.img[0],  // 첫 번째 이미지 사용
                          fit: BoxFit.cover,  // 이미지를 컨테이너에 맞춤
                        )
                            : Container(
                          color: Colors.grey[300],  // 이미지가 없을 때 회색 배경
                          child: Center(
                            child: Text(
                              '이미지 없음',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),  // 이미지와 텍스트 간격
                    Text(
                      '${sellPost.price}원',  // 가격 정보
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4),  // 가격과 제목 간격
                    Text(
                      sellPost.title,  // 제목 정보
                      maxLines: 2,  // 두 줄까지만 표시
                      overflow: TextOverflow.ellipsis,  // 제목이 길면 생략
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              );
            },
          );
        },
      )
          : Center(
        child: Text('검색어를 입력하고 검색 버튼을 눌러주세요.'),
      ),
    );
  }
}
