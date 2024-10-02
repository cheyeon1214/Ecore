import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../donation_page/dona_detail.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/user_model.dart';

class MyDonaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 기부글 목록'),
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          final myPosts = userModel.myPosts; // my_posts 배열 가져오기

          if (myPosts.isEmpty) {
            return Center(child: Text('등록한 기부글이 없습니다.'));
          }

          return FutureBuilder<List<DonaPostModel>>(
            future: _getMyDonaPosts(myPosts), // my_posts에 해당하는 기부글 불러오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final donaPosts = snapshot.data ?? [];

              if (donaPosts.isEmpty) {
                return Center(child: Text('등록한 기부글이 없습니다.'));
              }

              return ListView.builder(
                itemCount: donaPosts.length,
                itemBuilder: (context, index) {
                  final post = donaPosts[index];
                  final String firstImageUrl = post.img.isNotEmpty
                      ? post.img[0]
                      : 'https://via.placeholder.com/100';

                  return ListTile(
                    leading: Image.network(
                      firstImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text('${post.body}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonaDetail(donaPost: post),
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

  // Firestore에서 my_posts 배열에 해당하는 기부 글들 가져오기
  Future<List<DonaPostModel>> _getMyDonaPosts(List<String> myPosts) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('DonaPosts')
          .where(FieldPath.documentId, whereIn: myPosts)
          .get();

      return querySnapshot.docs
          .map((doc) => DonaPostModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching dona posts: $e');
      return [];
    }
  }
}
