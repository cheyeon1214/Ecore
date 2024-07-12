import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CareouselSlider extends StatefulWidget {
  const CareouselSlider({super.key});

  @override
  State<CareouselSlider> createState() => _CareouselSliderState();
}

class _CareouselSliderState extends State<CareouselSlider> {
  final List<String> imgList = [
    'https://via.placeholder.com/600x400/8f8e94/FFFFFF?text=1',
    'https://via.placeholder.com/600x400/8f8e94/FFFFFF?text=2',
    'https://via.placeholder.com/600x400/8f8e94/FFFFFF?text=3',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imgList.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
          Container(
            child: Image.network(imgList[itemIndex], fit: BoxFit.cover),
          ),
      options: CarouselOptions(
        height: 200,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 4),
        // enlargeCenterPage: true, //중앙 화면만 뜨도록 해줌
      ),
    );
  }
}


