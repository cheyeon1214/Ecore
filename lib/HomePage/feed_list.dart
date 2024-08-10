import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'carousel_slider.dart';
import 'category_button.dart';
import 'feed_detail.dart';

class Feed extends StatefulWidget {
  const Feed({super.key,});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String _selectedCategory = ''; // 기본값

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Center(child: CareouselSlider()),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CategoryBtn(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category; // 카테고리 선택 시 업데이트
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedCategory.isEmpty
                ? FirebaseFirestore.instance.collection('SellPosts').snapshots()
                : FirebaseFirestore.instance
                .collection('SellPosts')
                .where('category', isEqualTo: _selectedCategory)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: data?.size ?? 0,
                itemBuilder: (context, index) {
                  final sellPost = SellPostModel.fromSnapshot(data!.docs[index]);
                  return _postHeader(sellPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _postHeader(SellPostModel sellPost) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetail(sellPost: sellPost),
          ),
        );
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.grey[200],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CachedNetworkImage(
              imageUrl: sellPost.img.isNotEmpty ? sellPost.img : 'https://via.placeholder.com/100',
              width: 100,
              height: 100,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sellPost.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
                Text('${sellPost.price}원', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'report') {
              } else if (value == 'hide') {
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'report',
                  child: Text('신고'),
                ),
                PopupMenuItem(
                  value: 'hide',
                  child: Text('숨기기'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}