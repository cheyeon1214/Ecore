import 'package:flutter/material.dart';

class MyMarketTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: '상품'),
              Tab(text: '피드'),
              Tab(text: '리뷰'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.blueGrey,
                      child: Center(
                        child: Text(
                          '상품 ${index + 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                Center(child: Text('피드 페이지')),
                Center(child: Text('리뷰 페이지')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
