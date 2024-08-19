import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_page/feed_detail.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/sell_post_model.dart';

class RecentViewedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('최근 본 상품'),
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return StreamBuilder<List<SellPostModel>>(
            stream: userModel.recentlyViewedStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final recentlyViewedPosts = snapshot.data ?? [];

              if (recentlyViewedPosts.isEmpty) {
                return Center(child: Text('최근 본 상품이 없습니다.'));
              }

              return ListView.builder(
                itemCount: recentlyViewedPosts.length,
                itemBuilder: (context, index) {
                  final post = recentlyViewedPosts[index];
                  return ListTile(
                    leading: Image.network(
                      post.img.isNotEmpty ? post.img : 'https://via.placeholder.com/100',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(post.title),
                    subtitle: Text('${post.price}원'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedDetail(sellPost: post),
                        ),
                      );
                    },
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
