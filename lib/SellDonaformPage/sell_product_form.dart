
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // 숫자 필터링을 위해 추가
import 'dart:io';

class sellproductform extends StatefulWidget {
  @override
  State<sellproductform> createState() => _SellProductFormState();
}

class _SellProductFormState extends State<sellproductform> {
  @override
  Widget build(BuildContext context) {
    return SalesForm();
  }
}

class SalesForm extends StatefulWidget {
  @override
  _SalesFormState createState() => _SalesFormState();
}

class _SalesFormState extends State<SalesForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final price = double.parse(_priceController.text);
      final category = _categoryValue;
      final body = _bodyController.text;
      final imageUrl = _image?.path;

      // Firestore에 데이터 저장
      try {
        await _firestore.collection('SellPosts').add({
          'title': title,
          'price': price,
          'category': category,
          'body': body,
          'img': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('판매 상품이 등록되었습니다.')),
        );

        Navigator.pop(context); // 이전 페이지로 돌아가기
      } catch (e) {
        print('Error adding document: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문서 추가 실패: $e')),
        );
      }
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _categoryValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매하기'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 돌아가기
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: getImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : Image.file(File(_image!.path)),
                    ),
                  ),
                  SizedBox(width: 16), // 이미지와 텍스트 폼 사이 간격
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '브랜드 이름이나 로고, 해짐 상태 등이 잘 보이도록 찍어주세요!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '상품명'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가격을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '카테고리'),
                value: _categoryValue,
                items: ['상의', '하의', '가방', '신발'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _categoryValue = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카테고리를 선택해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: '자세한 설명',
                  hintText: '재질이나 색 등 옷의 상태를 설명해주세요',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '자세한 설명을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('판매하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}