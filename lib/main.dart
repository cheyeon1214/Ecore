import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'models/firebase_auth_state.dart';
import 'models/firestore/user_model.dart';
import 'package:ecore/HomePage/home_page_menu.dart';
import 'package:ecore/signInUpPage/sign_in_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthState>(
          create: (_) => FirebaseAuthState(),
        ),
        ChangeNotifierProxyProvider<FirebaseAuthState, UserModel>(
          create: (_) => UserModel(),
          update: (context, authState, userModel) {
            if (authState.user != null) {
              userModel?.fetchUserData(authState.user!.uid);
            }
            return userModel!;
          },
        ),
      ],
      child: Consumer<FirebaseAuthState>(
        builder: (context, authState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: authState.firebaseAuthStatus == FirebaseAuthStatus.signin
                ? HomePage() // 로그인 상태이면 홈 화면
                : SignInForm(), // 비로그인 상태이면 로그인 화면
          );
        },
      ),
    );
  }
}
