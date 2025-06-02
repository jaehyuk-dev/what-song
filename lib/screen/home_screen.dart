import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const HomeScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181E2A),
      body: Column(
        children: [
          // 메인 컨텐츠 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        color: const Color(0xFFFF7A5A), // 포인트 컬러 적용
                        size: 28, // 아이콘 크기를 약간 줄여 텍스트와 조화롭게 조정
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '코노코노',
                        style: TextStyle(
                          fontSize: 28, // 기존 32에서 살짝 줄여 아이콘과 균형을 맞춤
                          fontWeight: FontWeight.w700, // 너무 과하지 않은 볼드체
                          color: const Color(0xFFFF7A5A), // ‘전체보기’ 버튼과 동일한 주황 계열 포인트 컬러
                          letterSpacing: 2, // 글자 간격을 조금 넓혀 시인성 강조
                          shadows: [
                            Shadow(
                              offset: const Offset(1.5, 1.5),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.music_note_rounded,
                        color: const Color(0xFFFF7A5A),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '안녕하세요 👋',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '오늘은 어떤 노래를 부르실까요?',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  // 오늘의 추천곡 카드
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('오늘의 추천곡',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 6),
                            Text('그대라는 시',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text('태연',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            SizedBox(height: 8),
                            // Text('TJ 12345',
                            //     style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 주변 노래방, 노래 검색 버튼
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF232B3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.place_outlined),
                          label: const Text('주변 노래방'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF232B3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.search),
                          label: const Text('번호 검색'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // 내 노래 리스트 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('내 노래 리스트',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('전체보기',
                            style: TextStyle(color: Color(0xFFFF7A5A))),
                      ),
                    ],
                  ),
                  // 노래 리스트
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF232B3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('마리아 (Maria)',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('화사',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                        Text('금영 2424',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF232B3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hype Boy',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('NewJeans',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                        Text('TJ 98765',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
