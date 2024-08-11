import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firebase_auth_state.dart'; // Provider 패키지 임포트

class MyPageBtn extends StatefulWidget {
  const MyPageBtn({super.key});

  @override
  State<MyPageBtn> createState() => _MyPageBtnState();
}

class _MyPageBtnState extends State<MyPageBtn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // 배경색 설정
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                  ),
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/market.png',
                        height: 40,
                      ),
                      Text(
                        '나의 마켓',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // 배경색 설정
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                  ),
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/cart.png',
                        height: 40,
                      ),
                      Text(
                        '주문-배송',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // 배경색 설정
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                  ),
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/review.png',
                        height: 40,
                      ),
                      Text(
                        '리뷰',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Provider.of<FirebaseAuthState>(context, listen: false).signOut();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50], // 배경색 설정
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                    ),
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/setting.png',
                          height: 40,
                          width: 35,
                        ),
                        Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // 포인트 내역 확인
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: Colors.blue[50],
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            child: Text(
              '이벤트 문구',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 5),
          TextButton(
            onPressed: () {
              // 배너 클릭 처리
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: Colors.blue[50],
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              minimumSize: Size(90, 60),
            ),
            child: Text(
              '배너',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
