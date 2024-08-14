import 'package:flutter/material.dart';
import 'search_feed_list.dart'; // SearchFeedList 위젯을 import 합니다.

class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final bool isDonationSearch;

  SearchResultsScreen({required this.results, required this.isDonationSearch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return SearchFeedList(result, isDonationSearch, context);
        },
      ),
    );
  }
}
