import 'package:flutter/material.dart';
import 'donation_search.dart';
import 'sell_posts_search.dart';
import 'search_result_screen.dart';
import 'market_search.dart';
import 'search_service.dart';

class SearchScreen extends StatefulWidget {
  final bool? isDonationSearch;

  SearchScreen({this.isDonationSearch});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DonationSearch _donationSearch = DonationSearch();
  final SellPostSearch _sellPostSearch = SellPostSearch();
  final MarketSearch _marketSearch = MarketSearch();
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() async {
    final recentSearches = await _searchService.getRecentSearches();
    setState(() {
      _recentSearches = _removeDuplicates(recentSearches);
    });
  }

  List<String> _removeDuplicates(List<String> searches) {
    // Set을 사용하여 중복 제거
    return searches.toSet().toList();
  }

  void _performSearch() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      return;
    }

    await _searchService.saveSearchTerm(query);
    _loadRecentSearches(); // 최근 검색어 갱신

    List<Map<String, dynamic>> donationResults = [];
    List<Map<String, dynamic>> sellPostResults = [];
    List<Map<String, dynamic>> marketResults = [];

    if (widget.isDonationSearch == true) {
      donationResults = await _donationSearch.searchDonations(query);
    } else if (widget.isDonationSearch == false) {
      sellPostResults = await _sellPostSearch.searchSellPosts(query);
    } else {
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

  void _onRecentSearchTap(String term) {
    _searchController.text = term;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recentSearches.map((term) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () => _onRecentSearchTap(term),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[100], // 배경색
                      borderRadius: BorderRadius.circular(20.0), // 동그란 모서리
                      border: Border.all(color: Colors.blue), // 테두리 색상
                    ),
                    child: Text(
                      term,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
