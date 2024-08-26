import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../home_page/feed_detail.dart';

class MyMarketProductpage extends StatelessWidget {
  final String marketId;

  const MyMarketProductpage({Key? key, required this.marketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SellPostModel>>(
      stream: FirebaseFirestore.instance
          .collection('SellPosts')
          .where('marketId', isEqualTo: marketId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => SellPostModel.fromSnapshot(doc)).toList()),
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

        var details = snapshot.data!;

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
  }
}
