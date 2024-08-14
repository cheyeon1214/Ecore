import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/view_counter.dart';

class DonaDetail extends StatefulWidget {
  final DonaPostModel donaPost;

  const DonaDetail({Key? key, required this.donaPost}) : super(key: key);

  @override
  State<DonaDetail> createState() => _DonaDetailState();
}

class _DonaDetailState extends State<DonaDetail> {

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      // Firestore에서 현재 문서의 reference를 사용하여 조회수 증가
      await incrementViewCount(widget.donaPost.reference);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

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
                  imageUrl: _getValidImageUrl(widget.donaPost.img),
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
                          widget.donaPost.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'User Name', // Placeholder name
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
                child: Text(widget.donaPost.body, style: TextStyle(fontSize: 16)),
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
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add functionality to add to cart
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
