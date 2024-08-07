import 'package:ecore/SellDonaformPage/sell_product_form.dart';
import 'package:flutter/material.dart';

class sellAndGive extends StatefulWidget {
  @override
  State<sellAndGive> createState() => _sellAndGiveState();
}

class _sellAndGiveState extends State<sellAndGive> {
  @override
  Widget build(BuildContext context) {
    return SellAndGive();
  }
}

class SellAndGive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로 가기 버튼을 눌렀을 때의 동작
            Navigator.pop(context);
          },
        ),
        title: Text(''), // 빈 텍스트로 설정하여 중앙 타이틀 제거
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'ecore',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, // 버튼의 너비를 설정
              child: ElevatedButton(
                onPressed: () {
                  // 기부하기 버튼을 눌렀을 때의 동작
                },
                child: Center(child: Text('기부')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // 버튼 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            SizedBox(height: 32), // 기부 버튼과 판매 버튼 사이의 간격을 설정
            Container(
              width: 200, // 버튼의 너비를 설정
              child: ElevatedButton(
                onPressed: () {
                  // 판매 제품 버튼을 눌렀을 때의 동작
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => sellproductform()));
                },
                child: Center(child: Text('판매 및 구매')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // 버튼 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
