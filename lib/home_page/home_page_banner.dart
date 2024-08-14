import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecore/home_page/feed_list.dart';
import '../search/search_screen.dart';

class TitleBanner extends StatefulWidget {
  const TitleBanner({super.key,});

  @override
  State<TitleBanner> createState() => _TitleBannerState();
}

class _TitleBannerState extends State<TitleBanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text('ecore'),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(isDonationSearch: false),
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.search,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
      body: Feed(),
    );
  }
}
