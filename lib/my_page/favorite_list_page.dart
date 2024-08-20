import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_page/feed_detail.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/sell_post_model.dart';

class FavoriteListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('찜 한 상품'),
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return StreamBuilder<List<SellPostModel>>(
            stream: userModel.favoriteListStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final recentlyViewedPosts = snapshot.data ?? [];

              if (recentlyViewedPosts.isEmpty) {
                return Center(child: Text('찜 한 상품이 없습니다.'));
              }

              return ListView.builder(
                itemCount: recentlyViewedPosts.length,
                itemBuilder: (context, index) {
                  final post = recentlyViewedPosts[index];
                  final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

                  return ListTile(
                    leading: Image.network(
                      firstImageUrl,
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
