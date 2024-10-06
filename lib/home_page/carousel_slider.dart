import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CareouselSlider extends StatefulWidget {
  const CareouselSlider({super.key});

  @override
  State<CareouselSlider> createState() => _CareouselSliderState();
}

class _CareouselSliderState extends State<CareouselSlider> {
  final List<String> imgList = [
    'assets/images/메인배너1.jpeg',
    'assets/images/메인배너2.jpeg',
    'assets/images/메인배너3.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imgList.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
          Container(
            child: Image.asset(imgList[itemIndex], fit: BoxFit.cover), // Image.asset로 변경
          ),
      options: CarouselOptions(
        height: 200,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 4),
        // enlargeCenterPage: true, // 중앙 화면만 뜨도록 해줌
      ),
    );
  }
}
