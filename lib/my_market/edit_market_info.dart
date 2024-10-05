import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 임포트
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage를 위한 임포트

import '../models/firestore/market_model.dart';

class EditMarketInfoPage extends StatefulWidget {
  final String marketId;

  EditMarketInfoPage({required this.marketId});

  @override
  _EditMarketInfoPageState createState() => _EditMarketInfoPageState();
}

class _EditMarketInfoPageState extends State<EditMarketInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _marketNameController = TextEditingController();
  final _marketDescriptionController = TextEditingController();
  final _csPhoneController = TextEditingController();
  final _csemailController = TextEditingController();

  String? _businessNumber;
  String? _profileImageUrl;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    try {
      DocumentSnapshot marketDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();
      if (marketDoc.exists) {
        Map<String, dynamic>? marketData =
        marketDoc.data() as Map<String, dynamic>?;

        _marketNameController.text = marketData?['name'] ?? '';
        _marketDescriptionController.text =
            (marketData?['feedPosts'] as List<dynamic>?)
                ?.join('\n') ??
                '';
        _csPhoneController.text = marketData?['cs_phone'] ?? '';
        _csemailController.text = marketData?['cs_email'] ?? '';
        _businessNumber = marketData?['business_number'];
        _profileImageUrl = marketData?['img'];
      }
    } catch (e) {
      print('Failed to load market data: $e');
    }
  }

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

  Future<void> _updateMarketInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      String marketName = _marketNameController.text;
      List<String> marketDescription = _marketDescriptionController.text.split('\n');
      String csPhone = _csPhoneController.text;
      String csemail = _csemailController.text;

      try {
        await FirebaseFirestore.instance.collection('Markets').doc(widget.marketId).update({
          'name': marketName,
          'feedPosts': marketDescription,
          'cs_phone': csPhone,
          'cs_email': csemail,
          'business_number': _businessNumber ?? '',
          'img': _profileImageUrl ?? '',
        });

        if (_image != null) {
          await _uploadImage(widget.marketId);

          await FirebaseFirestore.instance
              .collection('Markets')
              .doc(widget.marketId)
              .update({
            'img': _profileImageUrl,
          });
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보가 수정되었습니다.')),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보 수정 중 오류가 발생했습니다.')),
        );
      }
    }
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
            backgroundImage: _image != null
                ? FileImage(File(_image!.path))
                : (_profileImageUrl != null
                ? NetworkImage(_profileImageUrl!) as ImageProvider
                : null),
            child: _image == null && _profileImageUrl == null
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 정보 수정'),
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
                Text(
                  _businessNumber != null
                      ? '사업자 번호: $_businessNumber'
                      : '사업자 등록 번호가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateMarketInfo,
                  child: Text('수정 완료'),
                ),
              ],
            ),
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
