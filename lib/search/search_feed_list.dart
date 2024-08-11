import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../DonationPage/dona_detail.dart';
import '../HomePage/feed_detail.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/sell_post_model.dart';

Widget SearchFeedList(Map<String, dynamic> result, bool _isDonationSearch, BuildContext context) {
  final imageUrl = result['img']?.toString() ?? 'https://via.placeholder.com/100';

  return InkWell(
    onTap: () {
      if (_isDonationSearch) {
        final donaPost = DonaPostModel.fromMap(result, '', reference: FirebaseFirestore.instance.collection('DonaPosts').doc());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonaDetail(donaPost: donaPost,),
          ),
        );
      } else {
        final sellPost = SellPostModel.fromMap(result, '', reference: FirebaseFirestore.instance.collection('SellPosts').doc());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetail(
              sellPost: sellPost,
            ),
          ),
        );
      }
    },
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
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
              Text(
                result['title'] ?? 'No Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              Text(
                result['body'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              if (!_isDonationSearch)
                Text(
                  '${result['price'] ?? 'No Price'}원',
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'report') {
              // 신고 처리 로직
            } else if (value == 'hide') {
              // 숨기기 처리 로직
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