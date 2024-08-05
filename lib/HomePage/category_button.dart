import 'package:flutter/material.dart';

class CategoryBtn extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;

  const CategoryBtn({required this.onCategorySelected, super.key});

  @override
  State<CategoryBtn> createState() => _CategoryBtnState();
}

class _CategoryBtnState extends State<CategoryBtn> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => widget.onCategorySelected('전체'),
          icon: Icon(Icons.list),
          iconSize: 60,
        ),
        IconButton(
          onPressed: () => widget.onCategorySelected('상의'),
          icon: Icon(Icons.eco),
          iconSize: 60,
        ),
        IconButton(
          onPressed: () => widget.onCategorySelected('하의'),
          icon: Icon(Icons.eco),
          iconSize: 60,
        ),
        IconButton(
          onPressed: () => widget.onCategorySelected('외투'),
          icon: Icon(Icons.eco),
          iconSize: 60,
        ),
        IconButton(
          onPressed: () => widget.onCategorySelected('신발'),
          icon: Icon(Icons.eco),
          iconSize: 60,
        ),
      ],
    );
  }
}
