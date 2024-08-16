import 'package:flutter/material.dart';

class ChattingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 창'), // 여기에서 채팅 창 텍스트를 설정
      ),
      body: Center(
        child: Text(
          '채팅 창',
          style: TextStyle(
            fontSize: 24, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
