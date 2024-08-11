// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:ecore/profile_screen.dart';
// // import 'package:ecore/screen_size.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/widgets.dart';
// // import 'package:provider/provider.dart';
// //
// // import 'cosntants/common_size.dart';
// // import 'models/user_model_state.dart';
// //
// // class ProfileBody extends StatefulWidget {
// //   final Function onMenuChanged;
// //
// //   const ProfileBody({super.key, required this.onMenuChanged});
// //   @override
// //   State<ProfileBody> createState() => _ProfileBodyState();
// // }
// // const duration = Duration(milliseconds: 1000); // 클래스 밖 변수 지정 => static 변수 // 이 값은 앱이 실행됨과 동시에 이 값 존재
// //
// //
// // class _ProfileBodyState extends State<ProfileBody> with SingleTickerProviderStateMixin {
// //   // const ProfileBody({super.key});
// //   SelectedTab _selectedTab = SelectedTab.left;
// //   bool selectedLeft = true;
// //   double _leftImagesPageMargin = 0;
// //   double _rightImagePageMargin = size!.width;
// //   late AnimationController _iconAnimationController;
// //
// //   @override
// //   void initState() {  // 해당 state가 새로 생성될 때 실행
// //     _iconAnimationController = AnimationController(vsync: this, duration: duration
// //     );
// //     // TODO: implement initState
// //     super.initState();
// //   }
// //
// //   @override
// //   void dispose() {  // 해당 state가 버려질 때 실행
// //     // TODO: implement dispose
// //     _iconAnimationController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: <Widget>[
// //           _appbar(),
// //           Expanded(
// //         child: CustomScrollView(  // 스크롤이 가능한 것이 있을 때
// //           slivers: <Widget>[
// //             SliverList(
// //               delegate: SliverChildListDelegate([
// //                 Row(
// //                   children: <Widget>[
// //                     Padding(
// //                       padding: const EdgeInsets.all(common_gap),
// //                       child: RoundedAvatar(
// //                         size: 100,
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Padding(
// //                         padding: const EdgeInsets.only(right: common_gap),
// //                         child: Table(
// //                           children: [
// //                             TableRow(
// //                                 children: [
// //                                   _valueText('123123'),
// //                                   _valueText('321321'),
// //                                   _valueText('123123'),
// //                                 ]
// //                             ),
// //                             TableRow(
// //                                 children: [
// //                                   _labelText('Post'),
// //                                   _labelText('Follwers'),
// //                                   _labelText('Following'),
// //                                 ]
// //                             )
// //                           ],
// //                         ),
// //                       ),
// //                     )
// //                   ],
// //                 ),
// //                 _username(context),
// //                 _userBio(),
// //                 _editProfileBtn(),
// //                 _tabButtons(),
// //                 _selectedIndicator()
// //               ],),
// //             ),
// //             _imagesPager()
// //           ],
// //         ),
// //       ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Row _appbar() {
// //     return Row(
// //       children: <Widget>[
// //         SizedBox(
// //           width: 44,
// //         ),
// //         Expanded(
// //             child: Text(
// //               'The Coding Yaewon',
// //               textAlign: TextAlign.center,
// //             )),
// //         IconButton(
// //           icon: AnimatedIcon(icon:AnimatedIcons.menu_close, progress: _iconAnimationController,),
// //           onPressed: () {
// //             widget.onMenuChanged();
// //             _iconAnimationController.status == AnimationStatus.completed
// //                 ? _iconAnimationController.reverse()
// //                 : _iconAnimationController.forward();
// //           },
// //         )
// //       ],
// //     );
// //   }
// //
// //   Text _valueText(String value) => Text(
// //     value,
// //     textAlign: TextAlign.center,
// //     style: TextStyle(
// //       fontWeight: FontWeight.bold,
// //     ),
// //   );
// //
// //   Text _labelText(String label) => Text(
// //     label,
// //     textAlign: TextAlign.center,
// //     style: TextStyle(
// //       fontWeight: FontWeight.w300,
// //       fontSize: 11
// //     ),
// //   );
// //
// //   SliverToBoxAdapter _imagesPager() {
// //     return SliverToBoxAdapter(
// //             child: Stack(
// //               children: [
// //                 AnimatedContainer(
// //                   duration: duration,
// //                   transform: Matrix4.translationValues(_leftImagesPageMargin, 0, 0),
// //                   child: _images(),
// //                 ),
// //                 AnimatedContainer(
// //                   duration: duration,
// //                   transform: Matrix4.translationValues(_rightImagePageMargin, 0, 0),
// //                   child: _images(),
// //                 ),
// //               ],
// //             ));
// //   }
// //
// //   GridView _images() {
// //     return GridView.count(
// //                           physics:NeverScrollableScrollPhysics(),
// //                           shrinkWrap:true,
// //                           crossAxisCount: 3,
// //                           childAspectRatio: 1,
// //                   children: List.generate(
// //                       30,
// //                           (index) => CachedNetworkImage(
// //                             fit: BoxFit.cover,
// //                               imageUrl: 'https://picsum.photos/id/$index/100/100',
// //                           )),
// //                 );
// //   }
// //
// //   Widget _selectedIndicator() {
// //     return AnimatedContainer(
// //       duration: Duration(milliseconds: 1000),
// //       alignment: _selectedTab==SelectedTab.left?Alignment.centerLeft:Alignment.centerRight,
// //       child: Container(
// //         height: 3,
// //         width: size?.width != null ? size!.width / 2 : 0,
// //         color: Colors.black87,
// //       ),
// //       curve: Curves.easeInOut,
// //     );
// //   }
// //
// //   Row _tabButtons() {
// //     return Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                 children: <Widget>[
// //                   Expanded(
// //                     child: IconButton(
// //                       icon: Icon(Icons.grid_3x3_outlined),
// //                       color: _selectedTab==SelectedTab.left ? Colors.black:Colors.black26,
// //                       onPressed: () {
// //                         _tabSelected(SelectedTab.left);
// //                       },
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: IconButton(
// //                       icon: Icon(Icons.save),
// //                       color: _selectedTab==SelectedTab.right ? Colors.black26:Colors.black,
// //                       onPressed: () {
// //                         _tabSelected(SelectedTab.right);
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               );
// //   }
// //
// //   _tabSelected(SelectedTab selectedTab) {
// //     setState(() {
// //       switch(selectedTab) {
// //         case SelectedTab.left:
// //           _selectedTab = SelectedTab.left;
// //           _leftImagesPageMargin = 0;
// //           _rightImagePageMargin = size!.width;
// //           break;
// //         case SelectedTab.right:
// //           _selectedTab = SelectedTab.right;
// //           _leftImagesPageMargin = -size!.width;
// //           _rightImagePageMargin = 0;
// //           break;
// //       }
// //     });
// //   }
// //
// //   Widget _editProfileBtn() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: common_gap, vertical: common_xxs_gap),
// //       child: SizedBox(
// //         height: 24,
// //         child: OutlinedButton(
// //           onPressed: () {},
// //           style: OutlinedButton.styleFrom(
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(6),
// //             ),
// //             side: const BorderSide(
// //               color: Colors.black45,
// //             ),
// //           ),
// //           child: const Text(
// //             'Edit Profile',
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //   //
// //   // Widget _username(BuildContext context) {
// //   //   return const Padding(
// //   //     padding: EdgeInsets.symmetric(horizontal: common_gap),
// //   //     child: Text(
// //   //       Provider.of<UserModelState>(context).userModel.username,
// //   //       style: TextStyle(fontWeight: FontWeight.bold),
// //   //     ),
// //   //   );
// //   // // }
// //   // Widget _username(BuildContext context) {
// //   //   return Padding(
// //   //     padding:  EdgeInsets.symmetric(horizontal: common_gap),
// //   //     child: Text(
// //   //       Provider.of<UserModelState>(context).userModel.username,
// //   //       style: const TextStyle(fontWeight: FontWeight.bold),
// //   //     ),
// //   //   );
// //   // }
// //   // Widget _username(BuildContext context) {
// //   //   UserModelState userModelState = Provider.of<UserModelState>(context);
// //   //   return Padding(
// //   //     padding: EdgeInsets.symmetric(horizontal: common_gap),
// //   //     child: Text(
// //   //       userModelState == null || userModelState.userModel == null
// //   //           ? ""
// //   //           : userModelState.userModel?.username,
// //   //       style: const TextStyle(fontWeight: FontWeight.bold),
// //   //     ),
// //   //   );
// //   // }
// //   Widget _username(BuildContext context) {
// //     UserModelState userModelState = Provider.of<UserModelState>(context);
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: common_gap),
// //       child: Text(
// //         userModelState.userModel?.username ?? "", // null일 경우 빈 문자열
// //         style: const TextStyle(fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// //
// //
// //
// //   Widget _userBio() {
// //     return const Padding(
// //       padding: EdgeInsets.symmetric(horizontal: common_gap),
// //       child: Text(
// //         'this is what I believe!!',
// //         style: TextStyle(fontWeight: FontWeight.w400),
// //       ),
// //     );
// //   }
// // }
// //
// // enum SelectedTab{left, right}
// //
// //
// // class RoundedAvatar extends StatelessWidget {
// //
// //   final double size;
// //   const RoundedAvatar({
// //     super.key, this.size = avatar_size}
// //       );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ClipOval(
// //       child: CachedNetworkImage(
// //         imageUrl: 'https://picsum.photos/100',
// //         width: avatar_size,
// //         height: avatar_size,
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:ecore/profile_screen.dart';
// import 'package:ecore/screen_size.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
//
// import 'cosntants/common_size.dart';
// import 'models/firebase_auth_state.dart';
// import 'models/user_model_state.dart';
//
// class ProfileBody extends StatefulWidget {
//   final Function onMenuChanged;
//
//   const ProfileBody({super.key, required this.onMenuChanged});
//   @override
//   State<ProfileBody> createState() => _ProfileBodyState();
// }
// const duration = Duration(milliseconds: 1000); // 클래스 밖 변수 지정 => static 변수 // 이 값은 앱이 실행됨과 동시에 이 값 존재
//
// class _ProfileBodyState extends State<ProfileBody> with SingleTickerProviderStateMixin {
//   SelectedTab _selectedTab = SelectedTab.left;
//   bool selectedLeft = true;
//   double _leftImagesPageMargin = 0;
//   double _rightImagePageMargin = size!.width;
//   late AnimationController _iconAnimationController;
//
//   @override
//   void initState() {  // 해당 state가 새로 생성될 때 실행
//     _iconAnimationController = AnimationController(vsync: this, duration: duration);
//     super.initState();
//   }
//
//   @override
//   void dispose() {  // 해당 state가 버려질 때 실행
//     _iconAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           _appbar(),
//           Expanded(
//             child: CustomScrollView(  // 스크롤이 가능한 것이 있을 때
//               slivers: <Widget>[
//                 SliverList(
//                   delegate: SliverChildListDelegate([
//                     Row(
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.all(common_gap),
//                           child: RoundedAvatar(size: 100),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(right: common_gap),
//                             child: Table(
//                               children: [
//                                 TableRow(children: [
//                                   _valueText('123123'),
//                                   _valueText('321321'),
//                                   _valueText('123123'),
//                                 ]),
//                                 TableRow(children: [
//                                   _labelText('Post'),
//                                   _labelText('Followers'),
//                                   _labelText('Following'),
//                                 ])
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     _username(context),
//                     _userBio(),
//                     _logoutBtn(context),
//                     _tabButtons(),
//                     _selectedIndicator()
//                   ]),
//                 ),
//                 _imagesPager()
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Row _appbar() {
//     return Row(
//       children: <Widget>[
//         SizedBox(width: 44),
//         Expanded(
//           child: Text(
//             'The Coding Yaewon',
//             textAlign: TextAlign.center,
//           ),
//         ),
//         IconButton(
//           icon: AnimatedIcon(
//             icon: AnimatedIcons.menu_close,
//             progress: _iconAnimationController,
//           ),
//           onPressed: () {
//             widget.onMenuChanged();
//             _iconAnimationController.status == AnimationStatus.completed
//                 ? _iconAnimationController.reverse()
//                 : _iconAnimationController.forward();
//           },
//         )
//       ],
//     );
//   }
//
//   Text _valueText(String value) => Text(
//     value,
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       fontWeight: FontWeight.bold,
//     ),
//   );
//
//   Text _labelText(String label) => Text(
//     label,
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       fontWeight: FontWeight.w300,
//       fontSize: 11,
//     ),
//   );
//
//   SliverToBoxAdapter _imagesPager() {
//     return SliverToBoxAdapter(
//       child: Stack(
//         children: [
//           AnimatedContainer(
//             duration: duration,
//             transform: Matrix4.translationValues(_leftImagesPageMargin, 0, 0),
//             child: _images(),
//           ),
//           AnimatedContainer(
//             duration: duration,
//             transform: Matrix4.translationValues(_rightImagePageMargin, 0, 0),
//             child: _images(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   GridView _images() {
//     return GridView.count(
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       crossAxisCount: 3,
//       childAspectRatio: 1,
//       children: List.generate(
//         30,
//             (index) => CachedNetworkImage(
//           fit: BoxFit.cover,
//           imageUrl: 'https://picsum.photos/id/$index/100/100',
//         ),
//       ),
//     );
//   }
//
//   Widget _selectedIndicator() {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 1000),
//       alignment: _selectedTab == SelectedTab.left
//           ? Alignment.centerLeft
//           : Alignment.centerRight,
//       child: Container(
//         height: 3,
//         width: size?.width != null ? size!.width / 2 : 0,
//         color: Colors.black87,
//       ),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   Row _tabButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: <Widget>[
//         Expanded(
//           child: IconButton(
//             icon: Icon(Icons.grid_3x3_outlined),
//             color: _selectedTab == SelectedTab.left
//                 ? Colors.black
//                 : Colors.black26,
//             onPressed: () {
//               _tabSelected(SelectedTab.left);
//             },
//           ),
//         ),
//         Expanded(
//           child: IconButton(
//             icon: Icon(Icons.save),
//             color: _selectedTab == SelectedTab.right
//                 ? Colors.black26
//                 : Colors.black,
//             onPressed: () {
//               _tabSelected(SelectedTab.right);
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   _tabSelected(SelectedTab selectedTab) {
//     setState(() {
//       switch (selectedTab) {
//         case SelectedTab.left:
//           _selectedTab = SelectedTab.left;
//           _leftImagesPageMargin = 0;
//           _rightImagePageMargin = size!.width;
//           break;
//         case SelectedTab.right:
//           _selectedTab = SelectedTab.right;
//           _leftImagesPageMargin = -size!.width;
//           _rightImagePageMargin = 0;
//           break;
//       }
//     });
//   }
//
//   Widget _logoutBtn(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//           horizontal: common_gap, vertical: common_xxs_gap),
//       child: SizedBox(
//         height: 24,
//         child: OutlinedButton(
//           onPressed: () {
//             Provider.of<FirebaseAuthState>(context, listen: false).signOut();
//           },
//           style: OutlinedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(6),
//             ),
//             side: const BorderSide(
//               color: Colors.black45,
//             ),
//           ),
//           child: const Text(
//             'Log out',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _username(BuildContext context) {
//     UserModelState userModelState = Provider.of<UserModelState>(context);
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: common_gap),
//       child: Text(
//         userModelState.userModel?.username ?? "", // null일 경우 빈 문자열
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _userBio() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: common_gap),
//       child: Text(
//         'this is what I believe!!',
//         style: TextStyle(
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }
//
// enum SelectedTab { left, right }
//
// class RoundedAvatar extends StatelessWidget {
//   final double size;
//   const RoundedAvatar({
//     super.key,
//     this.size = avatar_size,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipOval(
//       child: CachedNetworkImage(
//         imageUrl: 'https://picsum.photos/100',
//         width: avatar_size,
//         height: avatar_size,
//       ),
//     );
//   }
// }
