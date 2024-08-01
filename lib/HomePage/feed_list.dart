import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecore/HomePage/category_button.dart';

import 'carousel_slider.dart';
import 'feed_detail.dart';

class Feed extends StatefulWidget {
  final int idx;
  const Feed(this.idx, {super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
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
          child: Center(child: CategoryBtn()),
        ), // 이 부분이 한 번만 나타남
        ...List.generate(10, (idx) => _postHeader(idx)), // _postHeader를 반복해서 생성
      ],
    );
  }

  Widget _postHeader(int idx) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextScreen(), // NextScreen()을 FeedDetail()로 변경
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/id/$idx/200',
              width: 100,
              height: 100,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
              children: [
                Text('업사이클링', style: TextStyle(color: Colors.black87)),
                Text('가격'),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              // Handle the actions for the selected menu item
              if (value == 'report') {
                // Handle report action
              } else if (value == 'hide') {
                // Handle hide action
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
