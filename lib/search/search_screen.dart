import 'package:flutter/material.dart';
import 'donation_search.dart';
import 'sell_posts_search.dart';
import 'search_result_screen.dart';
import 'market_search.dart';

class SearchScreen extends StatefulWidget {
  final bool? isDonationSearch; // Change to bool?

  SearchScreen({this.isDonationSearch});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}


class _SearchScreenState extends State<SearchScreen> {
  final DonationSearch _donationSearch = DonationSearch();
  final SellPostSearch _sellPostSearch = SellPostSearch();
  final MarketSearch _marketSearch = MarketSearch();
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      return;
    }

    List<Map<String, dynamic>> donationResults = [];
    List<Map<String, dynamic>> sellPostResults = [];
    List<Map<String, dynamic>> marketResults = [];

    if (widget.isDonationSearch == true) {
      donationResults = await _donationSearch.searchDonations(query);
    } else if (widget.isDonationSearch == false) {
      sellPostResults = await _sellPostSearch.searchSellPosts(query);
    } else {
      // 전체 검색 수행
      donationResults = await _donationSearch.searchDonations(query);
      sellPostResults = await _sellPostSearch.searchSellPosts(query);
      marketResults = await _marketSearch.searchMarkets(query);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          donationResults: donationResults,
          sellPostResults: sellPostResults,
          marketResults: marketResults,
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
                hintText: '검색어를 입력해주세요',
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