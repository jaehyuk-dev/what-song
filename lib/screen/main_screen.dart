import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/loading_service.dart';
import 'home_screen.dart';
import 'setting_screen.dart';
import 'song_list_screen.dart';
import 'search_store_screen.dart'; // SearchRoomScreen 임포트 추가
import '../core/tab_change_callback.dart';

class MainScreen extends StatefulWidget {
  final TabChangeCallback? onTabChange;
  const MainScreen({super.key, this.onTabChange});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _searchShowFavorites = false;

  // 네비게이션 아이템 선택 시 호출되는 함수
  void _onItemTapped(int index, {bool showFavorites = false}) {
    // 탐색하기 탭(인덱스 1)을 누른 경우 지도 열기
    if (index == 1 && !showFavorites) {
      _launchNaverMap();
      return; // 함수 종료하여 화면 변경 방지
    }

    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _searchShowFavorites = showFavorites;
        _screens[1] = SearchStoreScreen(showFavorites: _searchShowFavorites);
      }
    });

    // 콜백 함수가 있으면 호출
    if (widget.onTabChange != null) {
      widget.onTabChange!(index, showFavorites: showFavorites);
    }
  }

  // 다른 화면으로 이동할 콘텐츠 준비
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // 화면 초기화 - 각 탭에 해당하는 화면 추가
    _screens = [
      HomeScreen(onTabChange: _onItemTapped),
      SearchStoreScreen(showFavorites: _searchShowFavorites),
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
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }


  Future<void> _launchNaverMap() async {
    try {
      await LoadingService.withLoading(() async {
        final encodedKeyword = Uri.encodeComponent("코인노래방");
        final appSchemeUrl = "nmap://search?query=$encodedKeyword&appname=com.app.lunch_mate";
        final webUrl = "https://m.map.naver.com/search2/search.naver?query=$encodedKeyword";

        // 네이버 지도 앱이 설치되어 있는지 확인
        if (await canLaunchUrl(Uri.parse(appSchemeUrl))) {
          await launchUrl(Uri.parse(appSchemeUrl));
        } else {
          // 앱이 없으면 웹 브라우저에서 열기
          await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        }
      });
    } catch (e) {
      print('네이버 지도 열기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지도 앱 실행 중 오류가 발생했습니다.')),
        );
      }
    }
  }
}