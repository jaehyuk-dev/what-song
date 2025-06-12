import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/loading_service.dart';
import 'home_screen.dart';
import 'setting_screen.dart';
import 'song_list_screen.dart';
import 'search_store_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const MainScreen({super.key, this.onTabChange});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // SongListScreen에 접근하기 위한 GlobalKey 추가
  final GlobalKey<SongListScreenState> _songListKey = GlobalKey<SongListScreenState>();

  // 네비게이션 아이템 선택 시 호출되는 함수 (수정됨)
  void _onItemTapped(int index, {bool shouldExpandFavorites = false}) {
    // 노래방 찾기 탭(인덱스 1)을 누른 경우 지도 열기
    if (index == 1) {
      _launchNaverMap();
      return; // 함수 종료하여 화면 변경 방지
    }

    setState(() {
      _currentIndex = index;
    });

    // 저장목록 탭으로 이동하면서 즐겨찾기 확장 요청이 있는 경우
    if (index == 2 && shouldExpandFavorites) {
      // 다음 프레임에서 즐겨찾기 확장 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _songListKey.currentState?.expandFavorites();
      });
    }

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

    // 화면 초기화 - 각 탭에 해당하는 화면 추가 (수정됨)
    _screens = [
      HomeScreen(onTabChange: _onItemTapped), // 수정된 콜백 전달
      const SearchStoreScreen(),
      SongListScreen(key: _songListKey), // GlobalKey 추가
      const SettingScreen(),
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF232B3A),
        selectedItemColor: const Color(0xFFFF7A5A),
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '노래방 찾기'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: '저장목록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        onTap: (index) => _onItemTapped(index), // 기본 탭만 전달
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