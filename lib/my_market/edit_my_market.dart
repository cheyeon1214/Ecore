import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditMarketProfilePage extends StatefulWidget {
  @override
  _EditMarketProfilePageState createState() => _EditMarketProfilePageState();
}

class _EditMarketProfilePageState extends State<EditMarketProfilePage> {
  File? _profileImage;
  File? _bannerImage;
  final _storeNameController = TextEditingController();

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // 여기에 프로필 저장 로직을 추가하세요.
    print('Store Name: ${_storeNameController.text}');
    if (_bannerImage != null) {
      print('Banner Image Path: ${_bannerImage!.path}');
    }
    if (_profileImage != null) {
      print('Profile Image Path: ${_profileImage!.path}');
    }
    // 저장 후 페이지를 닫거나 알림을 표시할 수 있습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 정보 편집'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.camera_alt, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text('마켓이름', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  hintText: '마켓이름 입력하세요',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 16),
              Text('배너 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickBannerImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: _bannerImage != null
                        ? DecorationImage(
                      image: FileImage(_bannerImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _bannerImage == null
                      ? Center(child: Icon(Icons.add_a_photo, color: Colors.grey[700], size: 50))
                      : null,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.symmetric(vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('적용하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
