//
// import 'package:ecore/signInUpPage/sign_up_form.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(SignInForm());
// }
//
// class SignInForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: LoginFormWidget(),
//         ),
//       ),
//     );
//   }
// }
//
// class LoginFormWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Image.asset('assets/images/ecore_logo.png'), // 로고 이미지 추가
//           SizedBox(height: 50.0), // 로고와 입력 필드 사이 간격
//           TextField(
//             decoration: InputDecoration(
//               labelText: '아이디',
//               hintText: '아이디를 입력하세요',
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           SizedBox(height: 20.0),
//           TextField(
//             obscureText: true,
//             decoration: InputDecoration(
//               labelText: '비밀번호',
//               hintText: '비밀번호를 입력하세요',
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           SizedBox(height: 30.0),
//           ElevatedButton(
//             onPressed: () {
//               // 로그인 버튼 눌렀을 때 처리
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue, // 버튼 배경 색상
//               foregroundColor: Colors.white, // 버튼 텍스트 색상
//               padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text('LOGIN'),
//           ),
//           SizedBox(height: 20.0),
//           TextButton(
//             onPressed: () {
//               // 아이디/비밀번호 찾기 처리
//             },
//             child: Text('아이디·비밀번호 찾기', style: TextStyle(color: Colors.black)),
//           ),
//           // Text(' / ', style: TextStyle(color: Colors.black)),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (context) => SignUpForm()));
//             },
//             child: Text('회원가입', style: TextStyle(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:path/path.dart';
// // import 'package:projectsangsang/models/firebase_auth_state.dart';
// // import 'package:provider/provider.dart';
// // import '../constants/auth_input_decor.dart';
// // import '../constants/common_size.dart';
// // import '../home_Page.dart';
// // import 'or_divider.dart';
// // import 'package:projectsangsang/widget/sign_up_form.dart';
// //
// // class SignInForm extends StatefulWidget {
// //   @override
// //   _SignInFormState createState() => _SignInFormState(); // 상태 클래스의 이름을 수정합니다.
// // }
// //
// // class _SignInFormState extends State<SignInForm> { // 상태 클래스의 이름을 수정합니다.
// //
// //   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// //
// //   TextEditingController _emailController = TextEditingController();
// //   TextEditingController _pwController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _pwController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       resizeToAvoidBottomInset: true,
// //       body: Padding(
// //         padding: const EdgeInsets.all(14),
// //         child: Form(
// //           key: _formKey,
// //           child: ListView(
// //             children: <Widget>[
// //               SizedBox(height: 16),
// //               Image.asset('assets/images/insta_text_logo.png'),
// //               TextFormField(
// //                 controller: _emailController,
// //                 cursorColor: Colors.black54,
// //                 decoration: textInputDecor('이메일'),
// //                 validator: (text) {
// //                   if (text != null && text.isNotEmpty && text.contains("@")) {
// //                     return null;
// //                   } else {
// //                     return '정확한 이메일 주소를 입력해주세요.';
// //                   }
// //                 },
// //               ),
// //               SizedBox(height: 10),
// //               TextFormField(
// //                 controller: _pwController,
// //                 cursorColor: Colors.black54,
// //                 obscureText: true,
// //                 decoration: textInputDecor('비밀번호'),
// //                 validator: (text) {
// //                   if (text != null && text.isNotEmpty && text.length > 5) {
// //                     return null;
// //                   } else {
// //                     return '비밀번호를 확인해주세요.';
// //                   }
// //                 },
// //               ),
// //               SizedBox(height:12),
// //               // _submitButton(context),
// //               SizedBox(height:12),
// //               OrDivider(),
// //               TextButton.icon(
// //                 onPressed: () {
// //                   Provider.of<FirebaseAuthState>(context, listen: false).changeFirebaseAuthStatus(FirebaseAuthStatus.signin);
// //                 },
// //                 label: Text("Login",
// //                     style: TextStyle(color: Colors.white)),
// //               ),
// //               TextButton(
// //                 onPressed: (){
// //
// //                 },
// //                 child: Align(
// //                   alignment: Alignment.centerRight,
// //                   child: Text(
// //                     '아이디/비밀번호 찾기',
// //                     style: TextStyle(color: Colors.black),
// //                   ),
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: (){
// //
// //                 },
// //                 child: Align(
// //                   alignment: Alignment.centerRight,
// //                   child: Text(
// //                     '회원가입',
// //                     style: TextStyle(color: Colors.black),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //   //
// //   // TextButton _submitButton(BuildContext context) {
// //   //   return TextButton(
// //   //     style: TextButton.styleFrom(
// //   //       backgroundColor: Colors.blue,
// //   //       shape: RoundedRectangleBorder(
// //   //         borderRadius: BorderRadius.circular(6),
// //   //       ),
// //   //     ),
// //   //     onPressed: () {
// //   //       if (_formKey.currentState?.validate() ?? false) {
// //   //         print('Validation success!!');
// //   //         Provider.of<FirebaseAuthState>(context, listen: false)
// //   //             .login(context, email: _emailController.text, password: _pwController.text);
// //   //       }
// //   //     },
// //   //     child: Text(
// //   //       'Sign In',
// //   //       style: TextStyle(color: Colors.white),
// //   //     ),
// //   //   );
// //   }
//
//
// import 'package:flutter/material.dart';
// import 'package:projectsangsang/widget/sign_up_form.dart';
//
// void main() {
//   runApp(SignInForm());
// }
//
// class SignInForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: LoginFormWidget(),
//         ),
//       ),
//     );
//   }
// }
//
// class LoginFormWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Image.asset('assets/images/ecore_logo.png', height: 100), // 로고 이미지 추가
//           SizedBox(height: 50.0), // 로고와 입력 필드 사이 간격
//           TextField(
//             decoration: InputDecoration(
//               labelText: '아이디',
//               hintText: '아이디를 입력하세요',
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           SizedBox(height: 20.0),
//           TextField(
//             obscureText: true,
//             decoration: InputDecoration(
//               labelText: '비밀번호',
//               hintText: '비밀번호를 입력하세요',
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           SizedBox(height: 30.0),
//           ElevatedButton(
//             onPressed: () {
//               // 로그인 버튼 눌렀을 때 처리
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue, // 버튼 배경 색상
//               foregroundColor: Colors.white, // 버튼 텍스트 색상
//               padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text('LOGIN'),
//           ),
//           SizedBox(height: 20.0),
//           TextButton(
//             onPressed: () {
//               // 아이디/비밀번호 찾기 처리
//             },
//             child: Text('아이디·비밀번호 찾기', style: TextStyle(color: Colors.black)),
//           ),
//           // Text(' / ', style: TextStyle(color: Colors.black)),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (context) => SignUpForm()));
//             },
//             child: Text('회원가입', style: TextStyle(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:ecore/HomePage/home_page_menu.dart';
import 'package:ecore/signInUpPage/sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../models/firebase_auth_state.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16),
              Image.asset('assets/images/ecore_logo.png'),
              SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                cursorColor: Colors.black54,
                decoration: textInputDecor('이메일'),
                validator: (text) {
                  if (text != null && text.isNotEmpty && text.contains("@")) {
                    return null;
                  } else {
                    return '정확한 이메일 주소를 입력해주세요.';
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pwController,
                cursorColor: Colors.black54,
                obscureText: true,
                decoration: textInputDecor('비밀번호'),
                validator: (text) {
                  if (text != null && text.isNotEmpty && text.length > 5) {
                    return null;
                  } else {
                    return '정확한 비밀번호를 입력해주세요.';
                  }
                },
              ),
              TextButton(
                onPressed: (){},
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '아이디 비밀번호 찾기',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 12),
              _submitButton(context),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('계정이 없으신가요? '),
            GestureDetector(
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text(
                '가입하기',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextButton _submitButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Color.fromRGBO(0, 0, 128, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          print('Validation success!!');
          Provider.of<FirebaseAuthState>(context, listen: false)
              .login(context, email: _emailController.text, password: _pwController.text);
        }
      },
      child: Text(
        'Sign In',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
