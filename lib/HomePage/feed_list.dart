import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecore/HomePage/category_button.dart';

import 'carousel_slider.dart';

class Feed extends StatelessWidget {
  final int idx;
  const Feed(this.idx, {super.key});

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

