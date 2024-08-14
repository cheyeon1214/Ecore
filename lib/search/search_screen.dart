import 'package:flutter/material.dart';
import 'donation_search.dart';
import 'sell_posts_search.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool isDonationSearch; // true면 기부글 검색, false면 판매글 검색

  SearchScreen({this.isDonationSearch = false});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DonationSearch _donationSearch = DonationSearch();
  final SellPostSearch _sellPostSearch = SellPostSearch();
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      return;
    }

    List<Map<String, dynamic>> results = [];

    if (widget.isDonationSearch) {
      results = await _donationSearch.searchDonations(query);
    } else {
      results = await _sellPostSearch.searchSellPosts(query);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          results: results,
          isDonationSearch: widget.isDonationSearch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text('Search'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.0),
            width: 290.0,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search...',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Center(
        // You can add additional widgets here, such as recent searches or popular searches
      ),
    );
  }
}
