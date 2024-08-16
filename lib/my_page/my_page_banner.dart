import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_page_button.dart';
import 'my_page_list.dart';

class MyPageBanner extends StatelessWidget {
  const MyPageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: BodyContents(),
    );
  }
}

class BodyContents extends StatelessWidget {
  const BodyContents({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasError) {
          return Center(child: Text('Error fetching user info'));
        } else if (!userSnapshot.hasData) {
          return Center(child: Text('No user logged in'));
        }

        User user = userSnapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (userDocSnapshot.hasError) {
              return Center(child: Text('Error fetching user details'));
            } else if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              return Center(child: Text('User details not found'));
            }

            var userData = userDocSnapshot.data!.data() as Map<String, dynamic>?;
            String userName = userData?['username'] ?? 'Unknown User';
            String userPoints = userData?['points']?.toString() ?? '0';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            // 클릭하면 사진 수정 가능
                          },
                          icon: Icon(Icons.people_alt_rounded, size: 50),
                        ),
                        SizedBox(width: 30,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$userName 님 반갑습니다.', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('포인트 보유 현황 : $userPoints', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                // 포인트 내역 확인
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                backgroundColor: Colors.blue[50],
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              ),
                              child: Text(
                                '포인트 내역 확인',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MyPageBtn(),
                    MyPageList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
}
