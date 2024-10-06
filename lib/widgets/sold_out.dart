import 'package:flutter/material.dart';

class SoldOutOverlay extends StatelessWidget {
  final bool isSoldOut;
  final double radius; // 원 크기를 설정할 수 있는 파라미터 추가

  const SoldOutOverlay({Key? key, required this.isSoldOut, this.radius = 50}) // 기본 radius 값을 50으로 설정
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isSoldOut
        ? Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6), // 배경을 원 안과 동일한 색으로 설정
        child: Center(
          child: CircleAvatar(
            radius: radius, // 페이지에서 전달받은 radius 값을 사용
            backgroundColor: Colors.transparent, // 원형 배경 투명 처리
            child: Container(
              width: radius * 2, // 원의 크기를 radius에 맞게 설정
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2), // 하얀색 테두리
                color: Colors.black.withOpacity(0.6), // 원형 배경 반투명 검정색
              ),
              child: Center(
                child: Text(
                  '판매 완료',
                  style: TextStyle(
                    color: Colors.white, // 텍스트를 화이트로 설정
                    fontSize: radius / 2.5, // radius에 비례한 텍스트 크기
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        : SizedBox.shrink(); // 재고가 있을 때는 빈 공간 반환
  }
}
