import 'package:flutter/material.dart';
import '../repo/DonaPostNetworkRepo.dart';
import '../repo/sell_post_network_repo.dart';

class CategoryBtn extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;

  const CategoryBtn({required this.onCategorySelected, super.key});

  @override
  State<CategoryBtn> createState() => _CategoryBtnState();
}

class _CategoryBtnState extends State<CategoryBtn> {
  final List<Map<String, String>> categories = [
    {'category': '상의', 'image': 'assets/images/shirt.png'},
    {'category': '하의', 'image': 'assets/images/jean.png'},
    {'category': '가방', 'image': 'assets/images/bag.png'},
    {'category': '신발', 'image': 'assets/images/shoes.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categories.map((category) {
        return IconButton(
          onPressed: () {
            sellPostNetworkRepo.getData(category['category']!);
            widget.onCategorySelected(category['category']!);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.lightBlue[50],
            fixedSize: Size(90, 90),
          ),
          icon: Container(
            width: 60,
            height: 60,
            child: Image.asset(category['image']!, fit: BoxFit.contain),
          ),
        );
      }).toList(),
    );
  }
}
