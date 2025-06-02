import 'package:flutter/material.dart';

import '../service/loading_service.dart';
import 'home_screen.dart';
import 'setting_screen.dart';
import 'song_list_screen.dart';
import 'search_store_screen.dart'; // SearchRoomScreen 임포트 추가

class MainScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const MainScreen({super.key, this.onTabChange});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 네비게이션 아이템 선택 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 콜백 함수가 있으면 호출
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
  }

  // 다른 화면으로 이동할 콘텐츠 준비
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // 화면 초기화 - 각 탭에 해당하는 화면 추가
    _screens = [
      HomeScreen(onTabChange: _onItemTapped),
      const SearchStoreScreen(), // 탐색하기 화면 추가
      const SongListScreen(), // 저장목록 화면 추가
      const SettingScreen(), // 설정 화면 추가
    ];
  }

  // 테스트용 비동기 함수
  void temp() async {
    await LoadingService.withLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181E2A),
      body: _screens[_currentIndex], // 현재 선택된 인덱스에 따라 화면 표시
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF232B3A),
        selectedItemColor: const Color(0xFFFF7A5A),
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex, // 현재 선택된 인덱스 설정
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '탐색하기'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: '저장목록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}