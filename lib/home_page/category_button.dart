import 'package:flutter/material.dart';
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
        return Padding(
            padding: EdgeInsets.only(right: 4, left: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50], // 배경색 설정
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
              ),
              child: IconButton(
                onPressed: () {
                  sellPostNetworkRepo.getData(category['category']!);
                  widget.onCategorySelected(category['category']!);
                },
                style: IconButton.styleFrom(
                  fixedSize: Size(85, 85),
                ),
                icon: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child:
                          Image.asset(category['image']!, fit: BoxFit.contain),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      category['category']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ));
      }).toList(),
    );
  }
}
