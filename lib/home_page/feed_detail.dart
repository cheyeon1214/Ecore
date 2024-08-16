import 'package:ecore/chat_page/chat_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  @override
  void initState() {
    super.initState();
    print('Market ID in initState: ${widget.sellPost.marketId}');
    _incrementViewCount();
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

    final userRef =
    FirebaseFirestore.instance.collection('Users').doc(user.uid);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: widget.sellPost.img,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  placeholder: (context, url) => CircularProgressIndicator(),
                ),
              ),
              SizedBox(height: 16),
              _marketInfoBuild(context),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                Text(widget.sellPost.body, style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
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
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    // Add favorite button functionality here
                  },
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.sellPost.price}원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _addToCart, // Updated to call _addToCart method
              icon: Icon(Icons.shopping_cart, color: Colors.black54),
              label: Text('장바구니 담기',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold)),
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
        String marketImage =
            marketData['img'] ?? 'https://via.placeholder.com/150';

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
        Column(
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
        Spacer(),
        IconButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatBanner()),
            );
          },
          icon: Icon(Icons.mail, size: 30),
        ),
        IconButton(
          onPressed: () async {
            bool isMatched = await isUserMarketMatched(widget.sellPost);
            if (isMatched) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatBanner()),
              );
            } else {
              print('User is not associated with the market of the sell post.');
            }
          },
          icon: Icon(Icons.mail_lock, size: 30),
        ),
      ],
    );
  }

}
