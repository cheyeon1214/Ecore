import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecore/HomePage/feed_list.dart';

class TitleBanner extends StatelessWidget {
  const TitleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                  child: Text('ecore')
              ),
              IconButton(
                  onPressed: null,
                  icon: Icon(CupertinoIcons.search, color: Colors.blueGrey,)
              ),
            ],
          ),
        ),
        body: Feed()
    );
  }
}