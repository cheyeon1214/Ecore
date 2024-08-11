import 'package:flutter/material.dart';
import 'donation_search.dart';
import 'search_feed_list.dart';
import 'sell_posts_search.dart';

class SearchScreen extends StatefulWidget {
  final bool isDonationSearch; // true면 기부글 검색, false면 판매글 검색

  SearchScreen({this.isDonationSearch = false});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DonationSearch _donationSearch = DonationSearch();
  final SellPostSearch _sellPostSearch = SellPostSearch();
  List<Map<String, dynamic>> _searchResults = [];
  late bool _isDonationSearch;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDonationSearch = widget.isDonationSearch;
  }

  void _performSearch() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    if (_isDonationSearch) {
      final results = await _donationSearch.searchDonations(query);
      print(results);
      setState(() {
        _searchResults = results;
      });
    } else {
      final results = await _sellPostSearch.searchSellPosts(query);
      print(results);
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.0),
            width: 330.0,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _performSearch(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search...',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return SearchFeedList(result, _isDonationSearch, context);
        },
      ),
    );
  }
}
