import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../HomePage/category_button.dart';
import '../models/firestore/dona_post_model.dart';
import 'dona_detail.dart';

class DonationList extends StatefulWidget {
  const DonationList( {super.key});

  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  String _selectedCategory = ''; // 기본값

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                ? FirebaseFirestore.instance.collection('DonaPosts').snapshots()
                : FirebaseFirestore.instance
                .collection('DonaPosts')
                .where('category', isEqualTo: _selectedCategory)
                .snapshots(),
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
                  final donaPost = DonaPostModel.fromSnapshot(data.docs[index]);
                  return _postHeader(donaPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _postHeader(DonaPostModel donaPost) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonaDetail(),
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
              imageUrl: donaPost.img.isNotEmpty ? donaPost.img : 'https://via.placeholder.com/100',
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
                Text(donaPost.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
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