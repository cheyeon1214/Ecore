import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'package:provider/provider.dart';

class FeedDetail extends StatelessWidget {
  final SellPostModel sellPost;

  const FeedDetail({Key? key, required this.sellPost,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: sellPost.img,
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
                child: Text(sellPost.body, style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNaviBar(userModel),
    );
  }

  BottomAppBar _bottomNaviBar(UserModel userModel) {
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
                  '${sellPost.price}원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                userModel.cart.add({
                  'marketID': sellPost.marketId,
                  'title': sellPost.title,
                  'img': sellPost.img,
                  'price': sellPost.price,
                  'category': sellPost.category,
                  'body': sellPost.body,
                  'reference': sellPost.reference.path, // Store the reference path as a string
                });
                userModel.updateCart(userModel.cart);
              },
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
    if (sellPost.marketId.isEmpty) {
      return Text('Invalid Market ID');
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Markets')
          .doc(sellPost.marketId)
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
                sellPost.title,
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
}
