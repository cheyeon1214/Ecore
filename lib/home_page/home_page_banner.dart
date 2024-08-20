import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/firestore/user_model.dart';
import '../my_page/favorite_list_page.dart';
import '../my_page/recently_viewed_page.dart';
import '../search/search_screen.dart';
import 'carousel_slider.dart';
import 'horizontal_list.dart';

class TitleBanner extends StatefulWidget {
  const TitleBanner({super.key});

  @override
  State<TitleBanner> createState() => _TitleBannerState();
}

class _TitleBannerState extends State<TitleBanner> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(child: CareouselSlider()),
            ),
            HorizontalListSection(
              stream: userModel.recentlyViewedStream,
              title: '최근 본 상품',
              onMorePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecentViewedPage(),
                  ),
                );
              },
            ),
            HorizontalListSection(
              stream: userModel.favoriteListStream,
              title: '찜한 상품',
              onMorePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteListPage(), // 실제 페이지로 변경
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
