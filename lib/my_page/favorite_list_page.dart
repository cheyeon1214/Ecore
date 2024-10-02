import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트
import '../home_page/feed_detail.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/sell_post_model.dart';

class FavoriteListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색 설정
        title: Text('찜 한 상품'), // 제목 설정
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return StreamBuilder<List<SellPostModel>>(
            stream: userModel.favoriteListStream, // FavoriteList 스트림 가져오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final favoritePosts = snapshot.data ?? []; // 찜 목록 데이터

              if (favoritePosts.isEmpty) {
                return Center(child: Text('찜 한 상품이 없습니다.')); // 찜 목록이 비었을 때 메시지
              }

              return GridView.builder(
                padding: EdgeInsets.all(8.0), // 그리드의 패딩 설정
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개
                  childAspectRatio: 0.65, // 카드 비율 조정
                  crossAxisSpacing: 8.0, // 열 간격
                  mainAxisSpacing: 8.0, // 행 간격
                ),
                itemCount: favoritePosts.length,
                itemBuilder: (context, index) {
                  final post = favoritePosts[index];
                  final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedDetail(sellPost: post),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2), // 둥글기 설정
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100, // 카드의 이미지 높이
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(2)), // 이미지 둥글기 조정
                                  image: DecorationImage(
                                    image: NetworkImage(firstImageUrl),
                                    fit: BoxFit.cover, // 이미지 비율 유지
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Text(
                                  '${post.price}원', // 가격을 상단에 배치
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 가격 글씨 크기 조정
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[900], // 특정 회색으로 변경
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5, // 더 위쪽으로 조정
                        child: IconButton(
                          icon: Icon(
                            // 하트 아이콘 상태
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final favoriteRef = FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .collection('FavoriteList')
                                  .doc(post.sellId);

                              // 찜 목록에서 제거
                              await favoriteRef.delete();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
