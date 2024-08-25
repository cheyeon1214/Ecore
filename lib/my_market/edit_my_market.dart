import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditMarketProfilePage extends StatefulWidget {
  final String marketId; // marketId를 필수 인자로 받음

  const EditMarketProfilePage({Key? key, required this.marketId}) : super(key: key);

  @override
  _EditMarketProfilePageState createState() => _EditMarketProfilePageState();
}

class _EditMarketProfilePageState extends State<EditMarketProfilePage> {
  File? _profileImage;
  File? _bannerImage;
  String? _currentProfileImageUrl;  // 현재 프로필 이미지 URL
  String? _currentBannerImageUrl;   // 현재 배너 이미지 URL
  final _storeNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentImages();
  }

  Future<void> _loadCurrentImages() async {
    DocumentSnapshot marketDoc = await _firestore.collection('Markets').doc(widget.marketId).get();
    if (marketDoc.exists) {
      setState(() {
        _currentProfileImageUrl = marketDoc['img'];
        _currentBannerImageUrl = marketDoc['bannerImg'];
        _storeNameController.text = marketDoc['name']; // 이전 이름을 텍스트 필드에 설정

      });
    }
  }

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

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // 고유한 파일 이름 생성
      final fileName = 'market_images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      final ref = _storage.ref().child(fileName);

      // Firebase Storage에 파일 업로드
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});

      // 업로드된 파일의 다운로드 URL 가져오기
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    try {
      // 로딩 중 다이얼로그 표시
      _showLoadingDialog();

      // 프로필 이미지와 배너 이미지를 Firebase Storage에 업로드
      String? profileImageUrl;
      String? bannerImageUrl;

      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      if (_bannerImage != null) {
        bannerImageUrl = await _uploadImage(_bannerImage!);
      }

      // Firestore에 업데이트할 데이터
      Map<String, dynamic> updateData = {
        'name': _storeNameController.text,
      };

      if (profileImageUrl != null) {
        updateData['img'] = profileImageUrl;
      }

      if (bannerImageUrl != null) {
        updateData['bannerImg'] = bannerImageUrl;
      }

      // Firestore에서 Markets 컬렉션의 해당 마켓 문서를 업데이트
      await _firestore.collection('Markets').doc(widget.marketId).update(updateData);

      // 로딩 중 다이얼로그 닫기
      Navigator.of(context).pop();

      // 성공 메시지 표시
      _showSuccessDialog();
    } catch (e) {
      // 로딩 중 다이얼로그 닫기
      Navigator.of(context).pop();

      print('Error updating profile: $e');
      // 에러 처리 로직 추가
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("로딩 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("완료"),
          content: Text("프로필 수정이 완료되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 이전 화면으로 돌아가기
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
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
                          : _currentProfileImageUrl != null
                          ? NetworkImage(_currentProfileImageUrl!)
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
                        : _currentBannerImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(_currentBannerImageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (_bannerImage == null && _currentBannerImageUrl == null)
                        Center(child: Icon(Icons.add_a_photo, color: Colors.grey[700], size: 50)),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue[50],
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
