// import 'package:ecore/profile_body.dart';
// import 'package:ecore/screen_size.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'dart:ui';
//
// import 'HomePage/profile_side_menu.dart';
//
// class ProfileScreen extends StatefulWidget {
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final duration = Duration(milliseconds: 300);
//   double menuWidth = 0;
//
//   MenuStatus _menuStatus = MenuStatus.closed;
//   double bodyXPos = 0;
//   double menuXPos = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     // MediaQuery를 사용하여 size 초기화
//     size = MediaQuery.of(context).size;
//
//     // size가 null이 아닌지 확인
//     if (size != null) {
//       menuWidth = size!.width / 2;
//       menuXPos = size!.width;
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Stack(
//         children: <Widget>[
//           AnimatedContainer(
//             duration: duration,
//             curve: Curves.fastOutSlowIn,
//             transform: Matrix4.translationValues(bodyXPos, 0, 0),
//             child: ProfileBody(
//               onMenuChanged: () {
//                 setState(() {
//                   _menuStatus = (_menuStatus == MenuStatus.closed)
//                       ? MenuStatus.opened
//                       : MenuStatus.closed;
//
//                   switch (_menuStatus) {
//                     case MenuStatus.opened:
//                       bodyXPos = -menuWidth;
//                       menuXPos = size!.width - menuWidth;
//                       break;
//                     case MenuStatus.closed:
//                       bodyXPos = 0;
//                       menuXPos = size!.width;
//                       break;
//                   }
//                 });
//               },
//             ),
//           ),
//           AnimatedContainer(
//             duration: duration,
//             transform: Matrix4.translationValues(menuXPos, 0, 0),
//             child: ProfileSideMenu(menuWidth),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// enum MenuStatus {
//   opened,
//   closed
// }
