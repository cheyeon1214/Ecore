import 'package:ecore/feed_list.dart';
import 'package:ecore/title_banner.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigationBarItem> btmNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
  ];

static List<Widget> _screens = <Widget>[
  TitleBanner(),
  Container(color: Colors.blue,),
  Container(color: Colors.red,),
  Container(color: Colors.purple,),
];

  int _selctedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // 이렇게 해줘야 누를 때마다 생성이 아닌 해당 페이지에 해당 인덱스 번호를 붙여준 것
        index: _selctedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false, // 눌렀을 때 안움직이게
        showUnselectedLabels: false,
        items: btmNavItems,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black87,
        currentIndex: _selctedIndex, // 현재 인덱스는 선택된 인덱스
        onTap: _onBtmItemClick, // 눌렀을 때 인덱스 값을 전달함 -> 함수 실행
      ),
    );
  }

  void _onBtmItemClick(int idx) {
    setState(() {
      _selctedIndex = idx;
    });
  }
}
