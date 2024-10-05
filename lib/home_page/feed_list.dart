import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'category_button.dart';
import 'feed_detail.dart';

class SellList extends StatefulWidget {
  final String selectedSort;
  const SellList({Key? key, required this.selectedSort}) : super(key: key);

  @override
  State<SellList> createState() => _SellListState();
}

class _SellListState extends State<SellList> {
  final UserModel userModel = UserModel(); // UserModel 인스턴스 생성
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CategoryBtn(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getQueryStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No posts found'));
              }

              final data = snapshot.data!;

              return GridView.builder(
                padding: EdgeInsets.all(8.0), // 그리드의 패딩 조정
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개의 아이템을 배치
                  crossAxisSpacing: 8.0, // 아이템 사이의 가로 간격
                  mainAxisSpacing: 0.0, // 아이템 사이의 세로 간격
                  childAspectRatio: 0.55, // 아이템의 비율 조정
                ),
                itemCount: data.size,
                itemBuilder: (context, index) {
                  final sellPost = SellPostModel.fromSnapshot(data.docs[index]);
                  return _postHeader(sellPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getQueryStream() {
    CollectionReference collection = FirebaseFirestore.instance.collection('SellPosts');

    Query query = collection;

    if (widget.selectedSort == '3') {
      query = query.orderBy('viewCount', descending: true);
    } else if (widget.selectedSort == '1') {
      query = query.orderBy('createdAt', descending: true);
    } else if (widget.selectedSort == '2') {
      query = query.orderBy('createdAt', descending: false);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    // 카테고리 필터 적용
    if (_selectedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }

  Widget _postHeader(SellPostModel sellPost) {
    final String firstImageUrl = sellPost.img.isNotEmpty ? sellPost.img[0] : 'https://via.placeholder.com/100';

    return GestureDetector(
      onTap: () {
        userModel.addRecentlyViewed(sellPost);  // Function call directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetail(sellPost: sellPost),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // 이미지의 둥근 모서리
                child: CachedNetworkImage(
                  imageUrl: firstImageUrl,
                  width: double.infinity,
                  height: 150, // 이미지의 높이 설정
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Positioned(
                top: -1,
                right: -4,
                child: IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // 하트 버튼 클릭 시 동작
                  },
                ),
              ),
              Positioned(
                top: 160, // 세로 버튼 위치를 더 아래로 이동
                right: -6,
                child: IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  onPressed: () {
                    // 세로 버튼 클릭 시 동작
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10), // 이미지와 텍스트 간의 간격 조정
          Text(
            '${sellPost.price}원',
            style: TextStyle(
              fontSize: 14, // 텍스트 크기를 줄여서 오버플로우 방지
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sellPost.title,
            style: TextStyle(
              fontSize: 12, // 가격 텍스트 크기 축소
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
