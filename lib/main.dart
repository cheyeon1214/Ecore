import 'package:ecore/home_page_menu.dart';
import 'package:flutter/material.dart';

void main() => runApp (MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}