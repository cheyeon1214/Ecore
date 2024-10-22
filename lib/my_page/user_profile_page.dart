import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../my_page/setting_page.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;  // 필수로 받아올 userId

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        centerTitle: true,  // 앱바 제목 중앙 배치
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firestore에서 userId를 이용해 username 및 profile_img 가져오기 (실시간)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중일 때
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('사용자 정보를 찾을 수 없습니다.')); // 데이터가 없을 때
                }

                // Firestore에서 실시간으로 가져온 데이터
                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                String userName = userData?['username'] ?? 'Unknown User'; // username 가져오기
                String profileImgUrl = userData?['profile_img'] ?? 'https://via.placeholder.com/150'; // profile_img 가져오기

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(profileImgUrl), // Firestore에서 가져온 profile_img 사용
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,  // Firestore에서 실시간으로 가져온 사용자 이름
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              // 별표와 평점 표시
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      if (index < 4) {
                                        return Icon(Icons.star, color: Colors.amber, size: 24);
                                      } else {
                                        return Icon(Icons.star_half, color: Colors.amber, size: 24); // 반별
                                      }
                                    }),
                                  ),
                                  SizedBox(width: 8),
                                  Text('4.5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 평점 표시
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 10),
            // 프로필 수정 버튼
            Center(  // Center로 중앙에 배치
              child: TextButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingPage(userId: userId), // userId 전달
                    ),
                  );
                },
                child: Text('프로필 수정', style: TextStyle(color: Colors.black)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],  // 배경 색상 설정
                  fixedSize: Size(360, 48),  // 버튼 크기 설정 (가로 360)
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(thickness: 1, color: Colors.grey), // 구분선

            // 기부 물품 섹션
            ListTile(
              title: Text('기부 물품 2개'),  // '판매물품'을 '기부 물품'으로 변경
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),

            // 받은 거래 후기 섹션
            ListTile(
              title: Text('받은 거래 후기'),  // '받은 매너 평가'를 '받은 거래 후기'로 변경
              subtitle: Text('받은 거래 후기가 아직 없어요.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
