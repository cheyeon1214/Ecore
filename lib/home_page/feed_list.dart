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
    // Use the first image in the list or a placeholder
    final String firstImageUrl = sellPost.img.isNotEmpty ? sellPost.img[0] : 'https://via.placeholder.com/100';

    return OutlinedButton(
      onPressed: () {
        userModel.addRecentlyViewed(sellPost);  // Function call directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetail(sellPost: sellPost),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!, width: 1), // Light gray border color
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0), // Increased vertical padding
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Adjust radius as needed
              child: CachedNetworkImage(
                imageUrl: firstImageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sellPost.title,
                  style: TextStyle(
                    fontSize: 20, // Increase font size
                    fontWeight: FontWeight.bold, // Make the font bold
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${sellPost.price}원',
                  style: TextStyle(
                    fontSize: 20, // Adjust font size for price
                    color: Colors.grey[700], // Change color to gray
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'report') {
                _showReportDialog();  // Show report dialog
              } else if (value == 'hide') {
                // Hide logic
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('신고 이유를 선택해주세요'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildReportOption('부적절한 내용'),
                _buildReportOption('스팸'),
                _buildReportOption('기타'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        // Handle the selection of the reason here
        Navigator.of(context).pop();
        // You could add additional logic to process the report
      },
    );
  }

}