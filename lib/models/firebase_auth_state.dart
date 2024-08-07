import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../repo/user_network_repository.dart';

class FirebaseAuthState extends ChangeNotifier{
  FirebaseAuthStatus _firebaseAuthStatus = FirebaseAuthStatus.signout;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  void watchAuthChange() {
    _firebaseAuth.authStateChanges().listen((user) {
      if(user == null && _user==null) {
        changeFirebaseAuthStatus();
        return;
      }else if(user != _user){
        _user = user;
        changeFirebaseAuthStatus();
      }
    });
  }

  void registerUser(BuildContext context,
      {required String email, required String password}) async {
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim())
        .catchError((error){
      print(error);
      String _message = "";
      switch(error.code) {
        case 'weak-password':
          _message = "패스워드 잘 넣어줘!!";
          break;
        case 'invalid-email':
          _message = "이메일 주소가 이상";
          break;
        case 'email-already-in-use':
          _message = "해당 email은 이미 사용 중";
          break;
      }

      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    _user = userCredential.user;
    if(_user==null) {
      SnackBar snackBar = SnackBar(
        content: Text("Please try again later"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else{
      //todo send data to firestore
      await userNetworkRepository.attemptCreateUser(userkey: _user!.uid, email: email!);
    }
  }

  void login(BuildContext context,
      {required String email, required String password}) async{
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
        email: email.trim(), password: password.trim())
        .catchError((error){
      print(error);
      String _message = "";
      switch(error.code) {
        case 'invalid-email':
          _message = "이메일 고쳐";
          break;
        case 'wrong-password':
          _message = "비밀번호 이상";
          break;
        case 'user-not-found':
          _message = "유저가 없다";
          break;
        case "user-disabled":
          _message = "해당 유저 금지되다";
          break;
        case "too-many-requests":
          _message = "너무 많은 시도, 나중에 다시 시도하라";
          break;
        case "operation-not-allowed":
          _message = "해당 동적 금지됨";
          break;
        default:
          _message = "알 수 없는 오류 발생";

      }
      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
    _user = userCredential.user;
    if(_user==null) {
      SnackBar snackBar = SnackBar(
        content: Text("Please try again later"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  void signOut() async {
    _firebaseAuthStatus = FirebaseAuthStatus.signout;
    if(_user != null) {
      _user = null;
      await _firebaseAuth.signOut();
    }
    notifyListeners();
  }

  void changeFirebaseAuthStatus([FirebaseAuthStatus? firebaseAuthStatus]){
    if(firebaseAuthStatus != null) {
      _firebaseAuthStatus = firebaseAuthStatus;
    }else {
      if(_firebaseAuthStatus != null) {
        _firebaseAuthStatus = FirebaseAuthStatus.signin;
      }else{
        _firebaseAuthStatus = FirebaseAuthStatus.signout;
      }
    }

    notifyListeners();
  }






  FirebaseAuthStatus get firbaseAuthStatus => _firebaseAuthStatus;
  User? get user => _user;
}

enum FirebaseAuthStatus{
  signout, progress, signin
}