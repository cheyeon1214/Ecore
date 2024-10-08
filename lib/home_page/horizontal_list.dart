import 'package:flutter/material.dart';
import '../donation_page/donation_page_banner.dart';
import '../models/firestore/sell_post_model.dart';
import 'feed_detail.dart';
import 'feed_list.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 위젯 임포트

class HorizontalListSection extends StatelessWidget {
  final Stream<List<SellPostModel>> stream;
  final String title;
  final VoidCallback onMorePressed;

  const HorizontalListSection({
    required this.stream,
    required this.title,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onMorePressed,
                child: Text(
                  '더보기',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 200, // Set height for the ListView
            child: StreamBuilder<List<SellPostModel>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: TextButton(
                      onPressed: () {
                        // 상품 보러가기 버튼 클릭 시 SellList로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonationBanner(),
                          ),
                        );
                      },
                      child: Text(
                        '상품 보러가기 🤣',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  );
                }

                final items = snapshot.data!.take(6).toList(); // Limit to 6 items

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final post = items[index];
                    final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/150';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedDetail(sellPost: post),
                          ),
                        );
                      },
                      child: Container(
                        width: 150, // Fixed width for each item
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack( // Stack 위젯으로 오버레이 적용
                              children: [
                                Container(
                                  height: 130, // Adjust height for the image
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0), // 모서리를 둥글게 설정
                                    child: Image.network(
                                      firstImageUrl, // 첫 번째 이미지를 사용
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // SoldOutOverlay를 이미지 위에 겹치게 설정
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0), // 둥글기 이미지와 동일하게 설정
                                    child: SoldOutOverlay(
                                      isSoldOut: post.stock == 0,
                                      radius: 30, // 원하는 크기로 radius 조정 가능
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '${post.price}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
