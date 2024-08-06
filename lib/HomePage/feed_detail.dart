import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/firestore/sell_post_model.dart';

class FeedDetail extends StatelessWidget {
  final SellPostModel sellPost;

  const FeedDetail({Key? key, required this.sellPost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: sellPost.img.isNotEmpty ? sellPost.img : 'https://via.placeholder.com/300',
                width: 300,
                height: 300,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 16),
            // Title and Profile Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/리유니클로.jpg'),
                  radius: 30,
                ),
                SizedBox(width: 16), // Space between profile and title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellPost.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, // Prevent overflow of title
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Market Name', // Placeholder name
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(sellPost.body, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
                  // Add to cart button functionality here
                },
                icon: Icon(Icons.shopping_cart, color: Colors.black54),
                label: Text('장바구니 담기', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Change button color if needed
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
