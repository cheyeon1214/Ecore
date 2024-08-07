
import 'package:flutter/material.dart';
import '../models/firestore/sell_post_model.dart';

class CartList extends StatelessWidget {

  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    SellPostModel? sellPost; //cart모델로 생성하기
    
    return TextButton(
      onPressed: () {},
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // child: CachedNetworkImage(
            //   imageUrl: sellPost.img.isNotEmpty ? sellPost.img : 'https://via.placeholder.com/100',
            //   width: 100,
            //   height: 100,
            //   errorWidget: (context, url, error) => Icon(Icons.error),
            // ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sellPost!.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
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
