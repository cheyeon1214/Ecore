import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/firestore/market_model.dart';

class MyMarketBanner extends StatelessWidget {
  final MarketModel market;

  MyMarketBanner({required this.market});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 버튼 동작
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // 배너 이미지 영역
            Container(
              height: 200,
              color: Colors.grey,
              child: Center(
                child: Text(
                  '배너',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            // 프로필과 검색창 영역
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: market.img.isNotEmpty
                        ? NetworkImage(market.img)
                        : AssetImage('assets/profile_image.jpg') as ImageProvider,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        market.name, // 현재 market 이름을 텍스트로 표시
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      // 메일 버튼 동작
                    },
                  ),
                ],
              ),
            ),
            // 탭 바
            TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: '상품'),
                Tab(text: '피드'),
                Tab(text: '리뷰'),
              ],
            ),
            // 탭 바 내용
            Expanded(
              child: TabBarView(
                children: [
                  // 상품 페이지
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Markets')
                        .doc(market.marketId) // marketId는 MarketModel에서 유일한 식별자로 사용
                        .collection('SellPosts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var Sellposts = snapshot.data!.docs;

                      return GridView.builder(
                        padding: EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: Sellposts.length,
                        itemBuilder: (context, index) {
                          var Sellpost = Sellposts[index];
                          var imgUrl = Sellpost['img'] ?? ''; // Sellpost의 img 필드 가져오기

                          return Container(
                            color: Colors.blueGrey,
                            child: imgUrl.isNotEmpty
                                ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                            )
                                : Center(
                              child: Text(
                                '상품 ${index + 1}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // 피드 페이지
                  Center(child: Text('피드 페이지')),
                  // 리뷰 페이지
                  Center(child: Text('리뷰 페이지')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
