import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../donation_page/donation_list.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'package:provider/provider.dart';
import '../widgets/view_counter.dart';

class FeedDetail extends StatefulWidget {
  final SellPostModel sellPost;

  const FeedDetail({Key? key, required this.sellPost}) : super(key: key);

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  int _currentIndex = 0; // 현재 사진의 인덱스를 저장할 변수
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    print('Market ID in initState: ${widget.sellPost.marketId}');
    _incrementViewCount();
    _checkIfFavorite(); // 추가: 즐겨찾기 상태를 확인하는 함수 호출
  }

  Future<void> _incrementViewCount() async {
    try {
      // Firestore에서 현재 문서의 reference를 사용하여 조회수 증가
      await incrementViewCount(widget.sellPost.reference);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      print('User not logged in');
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      // User document does not exist
      print('User document does not exist');
      return;
    }

    final cart = userDoc.data()?['cart'] ?? [];
    final newCartItem = {
      'sellId': widget.sellPost.sellId,
      'title': widget.sellPost.title,
      'img': widget.sellPost.img,
      'price': widget.sellPost.price,
      'category': widget.sellPost.category,
      'body': widget.sellPost.body,
      'reference': widget.sellPost.reference.path,
    };

    // Add the new item to the cart
    cart.add(newCartItem);

    // Update the user's cart in Firestore
    await userRef.update({'cart': cart});
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('FavoriteList')
          .doc(widget.sellPost.sellId);

      final doc = await favoriteRef.get();
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    if (_isFavorite) {
      // Remove from wishlist
      final favoriteRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('FavoriteList')
          .doc(widget.sellPost.sellId);

      await favoriteRef.delete();
    } else {
      // Add to wishlist
      await userModel.addItemToWishlist(widget.sellPost);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(widget.sellPost.img), // 이미지 리스트 처리
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _marketInfoBuild(context),
                  SizedBox(height: 16),
                  Text(widget.sellPost.body, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNaviBar(),
    );
  }

  BottomAppBar _bottomNaviBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black54,
                  ),
                  onPressed: _toggleFavorite,
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.sellPost.price}원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _addToCart,
              icon: Icon(Icons.shopping_cart, color: Colors.black54),
              label: Text('장바구니 담기', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketInfoBuild(BuildContext context) {
    if (widget.sellPost.marketId.isEmpty) {
      return Text('마켓 정보가 없어요~!');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.sellPost.marketId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error fetching market data: ${snapshot.error}');
          return Text('Failed to load market info');
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Market not found');
        }

        var marketData = snapshot.data!.data() as Map<String, dynamic>?;

        if (marketData == null) {
          return Text('Market data is not available');
        }

        String marketName = marketData['name'] ?? 'Unknown Market';
        String marketImage = marketData['img'] ?? 'https://via.placeholder.com/150';

        return _marketView(marketImage, marketName);
      },
    );
  }

  Row _marketView(String marketImage, String marketName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(marketImage),
          radius: 30,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sellPost.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                marketName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Text('이미지가 없습니다.');
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width, // 화면의 가로 크기와 동일한 너비 설정
      height: MediaQuery.of(context).size.width, // 화면의 가로 크기와 동일한 높이 설정
      child: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,  // 이미지를 가로폭에 맞춰 전체 화면에 걸쳐 표시
                errorWidget: (context, url, error) => Icon(Icons.error),
                placeholder: (context, url) => CircularProgressIndicator(),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                '${_currentIndex + 1}/${images.length}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
