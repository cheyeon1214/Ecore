import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/my_market/edit_my_market.dart';
import 'package:ecore/my_market/my_market_feedpage.dart';
import 'package:flutter/material.dart';
import '../home_page/feed_detail.dart';
import '../models/firestore/market_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../sell_donation_page/sell_product_form.dart';

class MyMarketBanner extends StatefulWidget {
  final MarketModel market;

  MyMarketBanner({required this.market});

  @override
  _MyMarketBannerState createState() => _MyMarketBannerState();
}

class _MyMarketBannerState extends State<MyMarketBanner> {
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
            // 배너 이미지와 글쓰기 버튼 영역
            Stack(
              children: [
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: TextButton.icon(
                    onPressed: () {
                      // 글쓰기 버튼 동작
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellProductForm(
                            name: widget.market.name, // marketId 전달
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text(
                      '글쓰기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3), // 반투명 배경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 프로필과 검색창 영역
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.market.img.isNotEmpty
                        ? NetworkImage(widget.market.img)
                        : AssetImage('assets/profile_image.jpg') as ImageProvider,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.market.name, // 현재 market 이름을 텍스트로 표시
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
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => EditMarketProfilePage()));
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
                  StreamBuilder<List<dynamic>>(
                    stream: widget.market.sellPostsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('오류 발생: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('상품이 없습니다.'));
                      }

                      var sellIds = snapshot.data!;

                      return FutureBuilder<List<SellPostModel>>(
                        future: _fetchSellPostDetails(sellIds),
                        builder: (context, detailsSnapshot) {
                          if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (detailsSnapshot.hasError) {
                            return Center(child: Text('오류 발생: ${detailsSnapshot.error}'));
                          }

                          if (!detailsSnapshot.hasData || detailsSnapshot.data!.isEmpty) {
                            return Center(child: Text('상품이 없습니다.'));
                          }

                          var details = detailsSnapshot.data!;

                          return GridView.builder(
                            padding: EdgeInsets.all(8.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: details.length,
                            itemBuilder: (context, index) {
                              var sellPost = details[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FeedDetail(sellPost: sellPost),
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.blueGrey,
                                  child: sellPost.img.isNotEmpty
                                      ? Image.network(
                                    sellPost.img[0],
                                    fit: BoxFit.cover,
                                  )
                                      : Center(
                                    child: Text(
                                      '이미지 없음',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // 피드 페이지
                  MyMarketFeedpage(),
                  // 리뷰 페이지
                  MyMarketReviewpage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<SellPostModel>> _fetchSellPostDetails(List<dynamic> sellIds) async {
    List<SellPostModel> details = [];

    for (var sellId in sellIds) {
      var document = await FirebaseFirestore.instance
          .collection('SellPosts')
          .doc(sellId)
          .get();

      if (document.exists) {
        var sellPost = SellPostModel.fromSnapshot(document);
        details.add(sellPost);
      }
    }

    return details;
  }
}

class MyMarketReviewpage extends StatelessWidget {
  const MyMarketReviewpage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('리뷰 페이지'));
  }
}

