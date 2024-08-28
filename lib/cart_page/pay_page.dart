import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cosntants/firestore_key.dart';


class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _phoneNumber;
  String? _address;
  List<Map<String, String>> _savedInfo = [];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      try {
        // Reference to the Firestore document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        // Fetching the username from the document
        setState(() {
          username = userDoc[KEY_NAME] ?? "No username";
        });
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          username = "Error loading username";
        });
      }
    }
  }

  void _saveInfo() {
    if (_phoneNumber != null && _phoneNumber!.isNotEmpty && _address != null && _address!.isNotEmpty) {
      setState(() {
        _savedInfo.add({'phone': _phoneNumber!, 'address': _address!});
        _phoneController.clear();
        _addressController.clear();
        _phoneNumber = '';
        _address = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            color: Colors.blue[200],
            child: Center(
              child: Text(
                "주문",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Text(
                '$username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(height: 10),
            ..._savedInfo.map((info) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '전화번호: ${info['phone']}, 배송지: ${info['address']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '전화번호를 입력해주세요.',
              ),
              maxLines: 1,
              onChanged: (value) {
                setState(() {
                  _phoneNumber = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '배송지를 입력해주세요.',
              ),
              maxLines: 1,
              onChanged: (value) {
                setState(() {
                  _address = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveInfo,
              child: Text("등록"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
