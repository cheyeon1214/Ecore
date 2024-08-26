import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // For input formatters
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;  // For HTTP requests
import 'dart:convert';  // For JSON encoding/decoding
import 'package:firebase_auth/firebase_auth.dart';

import '../home_page/home_page_menu.dart';
import '../models/firestore/market_model.dart';
import 'my_market_banner.dart';  // For Firebase Auth

class MarketInfoPage extends StatefulWidget {
  final String seller_name;
  final String dob;
  final String? gender;
  final String phone;
  final String email;
  final String address;

  MarketInfoPage({
    required this.seller_name,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  _MarketInfoPageState createState() => _MarketInfoPageState();
}

class _MarketInfoPageState extends State<MarketInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _marketNameController = TextEditingController();
  final _marketDescriptionController = TextEditingController();
  final _csPhoneController = TextEditingController();
  final _csemailController = TextEditingController();
  final _businessNumberController = TextEditingController();

  bool _isBusinessNumberChecked = false;
  bool _isBusinessNumberVerified = false;

  Future<void> _checkBusinessNumber() async {
    String businessNumber = _businessNumberController.text;

    var data = {"b_no": [businessNumber]};
    String serviceKey = "AC9zdZTlBsdv4Ylv3CdSllj0yXx6N7SjO%2FieWH0EiNu8CpZLRkxJ%2Ba9b1IkI3kI1Y40eIIMfJIEndaYW9ma3zg%3D%3D";

    try {
      var response = await http.post(
        Uri.parse("https://api.odcloud.kr/api/nts-businessman/v1/status?serviceKey=$serviceKey"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['match_cnt'] == 1) {
          setState(() {
            _isBusinessNumberChecked = true;
            _isBusinessNumberVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사업자 등록번호가 확인되었습니다.')),
          );
        } else {
          setState(() {
            _isBusinessNumberVerified = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사업자 등록번호 확인 실패.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    }
  }

  Future<void> _submitMarketInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      String marketName = _marketNameController.text;
      List<String> marketDescription = _marketDescriptionController.text.split('\n');
      String csPhone = _csPhoneController.text;
      String csemail = _csemailController.text;
      String businessNumber = _businessNumberController.text;

      // 현재 유저 아이디 가져오기
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (_isBusinessNumberChecked && !_isBusinessNumberVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사업자 등록번호를 먼저 확인해 주세요.')),
        );
        return;
      }

      try {
        // Add the market info to Firestore
        DocumentReference docRef = await FirebaseFirestore.instance.collection('Markets').add({
          'name': marketName,
          'feedPosts': marketDescription,
          'cs_phone': csPhone,
          'cs_email': csemail,
          'business_number': businessNumber.isEmpty ? '' : businessNumber,
          'userId': userId, // 현재 유저 ID 추가
          'seller_name': widget.seller_name,
          'dob': widget.dob,
          'gender': widget.gender,
          'phone': widget.phone,
          'email': widget.email,
          'address': widget.address,
        });

        // Get the document ID
        String marketId = docRef.id;

        if (userId != null) {
          await FirebaseFirestore.instance.collection('Users').doc(userId).update({
            'marketId': marketId,
          });
        }

        DocumentSnapshot marketDoc = await FirebaseFirestore.instance
            .collection('Markets')
            .doc(marketId)
            .get();
        MarketModel market = MarketModel.fromSnapshot(marketDoc);

        // Navigate to MyMarketBanner with the document ID
        // HomePage로 네비게이션 할 때
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,  // 모든 기존 페이지를 제거하고 새로운 페이지로 이동
        );


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보가 제출되었습니다.')),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 정보 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _marketNameController,
                label: '마켓 이름',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '마켓 이름을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _marketDescriptionController,
                label: '소개글',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '소개글을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _csPhoneController,
                label: 'CS 전화번호',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CS 전화번호를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _csemailController,
                label: 'CS 이메일',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요.';
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return '유효한 이메일 주소를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '사업자 등록 번호가 존재하면 인증마크가 부여됩니다.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5),
              _buildTextField(
                controller: _businessNumberController,
                label: '사업자 등록번호',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _checkBusinessNumber,
                    child: Text('사업자 등록번호 조회'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitMarketInfo,
                    child: Text('제출'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}
