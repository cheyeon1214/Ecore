import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위해 추가


class MyMarketReviewPage extends StatelessWidget {
  final String marketId; // 마켓 ID를 받음

  const MyMarketReviewPage({Key? key, required this.marketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reviews')
            .where('marketId', isEqualTo: marketId) // 해당 marketId의 리뷰만 필터링
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('리뷰가 없습니다.'));
          }

          final reviews = snapshot.data!.docs;
          double totalRating = 0;
          int totalReviews = reviews.length;

          // 총 평점 계산
          reviews.forEach((doc) {
            totalRating += doc['rating'];
          });

          double averageRating = totalRating / totalReviews;
          int satisfactionCount = reviews
              .where((doc) => doc['satisfaction'] == '예') // 만족도를 필터링
              .length;
          double satisfactionPercentage =
              (satisfactionCount / totalReviews) * 100;

          return Column(
            children: [
              // 상단에 평균 평점과 만족도 비율을 표시
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '이 상점의 거래후기 $totalReviews',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${satisfactionPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('만족후기'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              // 리뷰 리스트 표시
              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // 리뷰 간 여백
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 별과 평점 부분
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text(
                                review['rating'].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // 평점 굵게
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          // 리뷰 내용 부분
                          Text(
                            review['review'],
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // 주문 ID와 작성일
                          Row(
                            children: [
                              Text(
                                review['orderId'], // 주문 ID 표시
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              SizedBox(width: 16),
                              Text(
                                DateFormat('yyyy-MM-dd').format(
                                  // Timestamp를 DateTime으로 변환 후 년-월-일 포맷으로 변환
                                  (review['timestamp'] as Timestamp).toDate(),
                                ),
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // 거래 상품 제목
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // 회색 배경으로 강조
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '거래상품  ${review['itemTitle']}', // 거래 상품 제목
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 8), // 다음 리뷰와의 간격을 유지하기 위한 여백
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
