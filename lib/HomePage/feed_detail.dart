import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      body: SingleChildScrollView(  // Wrap Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: _getValidImageUrl(sellPost.img),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  placeholder: (context, url) => CircularProgressIndicator(),
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
                          overflow: TextOverflow.ellipsis,
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
                  userModel.cart.add({
                    'marketID': sellPost.marketID,
                    'title': sellPost.title,
                    'img': sellPost.img,
                    'price': sellPost.price,
                    'category': sellPost.category,
                    'body': sellPost.body,
                    'reference': sellPost.reference,
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
      ),
    );
  }

  // Helper method to ensure a valid image URL is used
  String _getValidImageUrl(String imageUrl) {
    if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.hasAbsolutePath ?? false) {
      return 'https://via.placeholder.com/300'; // Default image URL
    }
    return imageUrl;
  }
}
