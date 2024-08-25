import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'carousel_slider.dart';
import 'category_button.dart';
import 'feed_detail.dart';

class SellList extends StatefulWidget {
  final String selectedSort;
  const SellList({Key? key, required this.selectedSort}) : super(key: key);

  @override
  State<SellList> createState() => _SellListState();
}

class _SellListState extends State<SellList> {
  final UserModel userModel = UserModel(); // UserModel 인스턴스 생성

  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CategoryBtn(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getQueryStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No posts found'));
              }

              final data = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.size,
                itemBuilder: (context, index) {
                  final sellPost = SellPostModel.fromSnapshot(data.docs[index]);
                  return _postHeader(sellPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getQueryStream() {
    CollectionReference collection = FirebaseFirestore.instance.collection('SellPosts');

    Query query = collection;

    if (widget.selectedSort == '3') {
      query = query.orderBy('viewCount', descending: true);
    } else if (widget.selectedSort == '1') {
      query = query.orderBy('createdAt', descending: true);
    } else if (widget.selectedSort == '2') {
      query = query.orderBy('createdAt', descending: false);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    // 카테고리 필터 적용
    if (_selectedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }

  Widget _postHeader(SellPostModel sellPost) {
    // 이미지 리스트에서 첫 번째 이미지를 사용
    final String firstImageUrl = sellPost.img.isNotEmpty ? sellPost.img[0] : 'https://via.placeholder.com/100';

    return TextButton(
      onPressed: () {
        userModel.addRecentlyViewed(sellPost);  // 함수 직접 실행
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
              imageUrl: firstImageUrl,
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
                // 신고 로직
              } else if (value == 'hide') {
                // 숨기기 로직
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