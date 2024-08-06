import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'donation_list.dart';

class DonationBanner extends StatelessWidget {
  const DonationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '기부',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildDropDown(),
          ),
          IconButton(
            onPressed: () {
              // 검색 버튼 동작 추가
            },
            icon: Icon(
              CupertinoIcons.search,
              color: Colors.blueGrey,
            ),
          ),
        ],
        backgroundColor: Colors.white, // 앱바 배경색
        elevation: 0, // 앱바 그림자 제거
      ),
      body: DonationList(),
    );
  }

  Widget _buildDropDown() {
    String dropDownValue = '1';
    List<String> dropDownList = ['1', '2', '3'];
    List<String> sortStr = ['최신순', '오래된순', '조회순'];

    return DropdownButton<String>(
      value: dropDownValue,
      items: dropDownList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(sortStr[int.parse(value) - 1]),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          dropDownValue = value;
          print(dropDownValue);
        }
      },
    );
  }
}