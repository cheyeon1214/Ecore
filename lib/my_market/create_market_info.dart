import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // 입력 포맷터를 위한 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;  // HTTP 요청을 위한 임포트
import 'dart:convert';  // JSON 인코딩/디코딩을 위한 임포트
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';  // 이미지 선택을 위한 임포트
import 'package:firebase_storage/firebase_storage.dart';  // Firebase Storage를 위한 임포트

import '../home_page/home_page_menu.dart';
import '../models/firestore/market_model.dart';
import 'my_market_banner.dart';  // Firebase Auth를 위한 임포트

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

  // 새로운 프로필 이미지 관련 변수
  String? _profileImageUrl;
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _uploadImage(String marketId) async {
    if (_image != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('market_images')
            .child('$marketId.jpg');

        await ref.putFile(File(_image!.path));
        String imageUrl = await ref.getDownloadURL();

        setState(() {
          _profileImageUrl = imageUrl;
        });
      } catch (e) {
        print('이미지 업로드 오류: $e');
      }
    }
  }

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

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (_isBusinessNumberChecked && !_isBusinessNumberVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사업자 등록번호를 먼저 확인해 주세요.')),
        );
        return;
      }

      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('Markets').add({
          'name': marketName,
          'feedPosts': marketDescription,
          'cs_phone': csPhone,
          'cs_email': csemail,
          'business_number': businessNumber.isEmpty ? '' : businessNumber,
          'userId': userId,
          'seller_name': widget.seller_name,
          'dob': widget.dob,
          'gender': widget.gender,
          'phone': widget.phone,
          'email': widget.email,
          'address': widget.address,
          'img': _profileImageUrl ?? '',
          'bannerImg': 'https://via.placeholder.com/150',
        });

        String marketId = docRef.id;

        if (_image != null) {
          await _uploadImage(marketId);

          await FirebaseFirestore.instance
              .collection('Markets')
              .doc(marketId)
              .update({
            'img': _profileImageUrl,
          });
        }

        if (userId != null) {
          await FirebaseFirestore.instance.collection('Users').doc(userId).update({
            'marketId': marketId,
          });
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
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
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 사진',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
            _image != null ? FileImage(File(_image!.path)) : null,
            child: _image == null
                ? Icon(
              Icons.add_a_photo,
              size: 50,
              color: Colors.grey,
            )
                : null,
          ),
        ),
        SizedBox(height: 16),
      ],
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
