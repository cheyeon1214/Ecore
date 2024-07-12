import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryBtn extends StatefulWidget {
  const CategoryBtn({super.key});

  @override
  State<CategoryBtn> createState() => _CategoryBtnState();
}

class _CategoryBtnState extends State<CategoryBtn> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed:() {}, style: IconButton.styleFrom(backgroundColor: Colors.lightBlue[50]), icon: Icon(Icons.eco), iconSize: 80,),
            IconButton(onPressed:() {}, style: IconButton.styleFrom(backgroundColor: Colors.lightBlue[50]), icon: Icon(Icons.eco), iconSize: 80,),
            IconButton(onPressed:() {}, style: IconButton.styleFrom(backgroundColor: Colors.lightBlue[50]), icon: Icon(Icons.eco), iconSize: 80,),
            IconButton(onPressed:() {}, style: IconButton.styleFrom(backgroundColor: Colors.lightBlue[50]), icon: Icon(Icons.eco), iconSize: 80,),
          ],
    );
  }
}
