import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecore/HomePage/category_button.dart';
import 'package:flutter/widgets.dart';

import 'carousel_slider.dart';

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
        ),// 이 부분이 한 번만 나타남
        ...List.generate(10, (idx) => _postHeader(idx)),
      ],// _postHeader를 10번 반복 생성 => 게시물 수만큼 반복 생성하도록 수정해야 됨
    );
  }

  Widget _postHeader(int idx){
    return Row(
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
            children: [
              Text('업사이클링'),
              Text('가격')
            ],
          ),
        ),
        IconButton(
            onPressed: null,
            icon: Icon(
              Icons.more_horiz,
              color: Colors.black87,
            )
        ),
      ],
    );
  }
}

