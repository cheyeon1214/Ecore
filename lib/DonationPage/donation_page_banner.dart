import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'donation_list.dart';

class DonationBanner extends StatelessWidget {
  const DonationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 20),
                      child: Text('기부', style: TextStyle(fontSize: 30)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 20),
                      child: Text('판매', style: TextStyle(fontSize: 30)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _buildDropDown(),
                    ),
                    Expanded(child: Container()),
                    IconButton(
                        onPressed: null,
                        icon: Icon(
                          CupertinoIcons.search,
                          color: Colors.blueGrey,
                        )),
                  ],
                ),
              ],
            ),
          ),
      body: ListView.builder(itemBuilder: DonationListBuilder, itemCount: 30),
    );
  }

  Widget _buildDropDown() {
    String dropDownValue = '1';
    List<String> dropDownList = ['1', '2', '3'];
    List<String> sortStr = ['최신순', '오래된순', '조회순'];

    if (dropDownValue == "") {
      dropDownValue = dropDownList.first;
    }

    return DropdownButton(
      value: dropDownValue,
      items: dropDownList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(sortStr[int.parse(value) - 1].toString()),
        );
      }).toList(),
      onChanged: (String? value) {
        dropDownValue = value!;
        print(dropDownValue);
      },
    );
  }

  Widget DonationListBuilder(BuildContext ctx, int idx) {
    return DonationList(idx);
  }
}
