import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/database_helper.dart';
import '../service/loading_service.dart';
import '../core/tab_change_callback.dart';

class HomeScreen extends StatefulWidget {
  final TabChangeCallback? onTabChange;

  const HomeScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _recentFavoriteSongs = [];
  Map<String, dynamic>? _randomRecommendedSong;

  @override
  void initState() {
    super.initState();
    _loadRecentFavoriteSongs();
    _loadRandomRecommendedSong();
  }

  // 동적 추천곡 카드 생성
  Widget _buildRecommendedSongCard() {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 추천곡',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  _randomRecommendedSong?['name'] ?? '즐겨찾기한 노래가 없어요',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _randomRecommendedSong?['singer'] ?? '노래를 추가해보세요!',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 버튼 그룹 (검색 + 새로고침)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 새로고침 버튼
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: () {
                  // 다른 랜덤 추천곡 로드
                  _loadRandomRecommendedSong();
                },
                icon: const Icon(Icons.refresh, size: 20),
              ),
              const SizedBox(height: 8),
              // 검색 버튼 - TJ미디어 사이트로 연결
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFC466B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: _randomRecommendedSong != null 
                  ? () {
                      // 추천곡이 있을 때만 검색 기능 실행
                      _searchSongNumber(
                        _randomRecommendedSong!['name'], 
                        _randomRecommendedSong!['singer']
                      );
                    }
                  : null, // 추천곡이 없으면 비활성화
                icon: const Icon(Icons.search, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 최근 즐겨찾기 노래 5개 로드 (id 역순으로)
  Future<void> _loadRecentFavoriteSongs() async {
    try {
      // ➊ DB에서 받은 결과를 가변 리스트로 복사
      final rawList = await _dbHelper.getFavoriteSongs();
      final allFavorites = List<Map<String, dynamic>>.from(rawList);

      // ➋ id 값이 큰 순서대로 정렬 (최신 순)
      allFavorites.sort((a, b) => b['id'].compareTo(a['id']));

      // ➌ 최대 5개만 가져와 _recentFavoriteSongs에 할당
      setState(() {
        _recentFavoriteSongs = allFavorites.take(5).toList();
      });
    } catch (e) {
      print('즐겨찾기 노래 로드 오류: $e');
    }
  }

  // 즐겨찾기 노래 중 랜덤 추천곡 로드
  Future<void> _loadRandomRecommendedSong() async {
    try {
      // ➊ DB에서 받은 결과를 가변 리스트로 복사
      final rawList = await _dbHelper.getFavoriteSongs();
      final allFavorites = List<Map<String, dynamic>>.from(rawList);

      // ➋ 즐겨찾기된 곡이 하나라도 있으면 랜덤 선택
      if (allFavorites.isNotEmpty) {
        final randomIndex = DateTime.now().millisecondsSinceEpoch % allFavorites.length;
        setState(() {
          _randomRecommendedSong = allFavorites[randomIndex];
        });
      } else {
        setState(() {
          _randomRecommendedSong = null;
        });
      }
    } catch (e) {
      print('추천곡 로드 오류: $e');
    }
  }

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
                      const Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFFFF7A5A), // 포인트 컬러 적용
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
                      const Icon(
                        Icons.music_note_rounded,
                        color: Color(0xFFFF7A5A),
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
                  // 동적 추천곡 카드
                  _buildRecommendedSongCard(),
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
                          onPressed: () {
                            _launchNaverMap();
                          },
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
                          onPressed: () {
                            _searchSongNumber("", "");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // 내 노래 리스트 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('즐겨찾기',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // 즐겨찾기 전체보기 - 탐색하기 탭으로 이동하며 즐겨찾기 섹션 확장
                          if (widget.onTabChange != null) {
                            widget.onTabChange!(1, showFavorites: true);
                          }
                        },
                        child: const Text('전체보기',
                            style: TextStyle(color: Color(0xFFFF7A5A))),
                      ),
                    ],
                  ),
                  // 동적 노래 리스트 (즐겨찾기 최신 5개)
                  ..._buildRecentFavoriteSongsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 최근 즐겨찾기 노래 리스트 UI 생성
  List<Widget> _buildRecentFavoriteSongsList() {
    if (_recentFavoriteSongs.isEmpty) {
      return [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232B3A),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: const Center(
            child: Text(
              '아직 즐겨찾기한 노래가 없습니다.\n노래를 추가하고 ❤️를 눌러보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }

    return _recentFavoriteSongs.map((song) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF232B3A),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song['singer'] ?? '',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 검색 버튼으로 변경
            IconButton(
              onPressed: () {
                // 검색 기능 구현 (추후 검색 화면으로 이동)
                _searchSongNumber(song['name'], song['singer']);
              },
              icon: const Icon(
                Icons.search,
                color: Color(0xFFFF7A5A),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF181E2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // 검색 다이얼로그 표시
  void _showSearchDialog(String songName, String singer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          title: const Text(
            '노래방 번호 검색',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '$songName - $singer\n\n이 노래의 노래방 번호를 검색하시겠습니까?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 실제 검색 기능 구현 (웹뷰나 외부 앱 연동)
                _performSearch(songName, singer);
              },
              child: const Text(
                '검색',
                style: TextStyle(color: Color(0xFFFF7A5A)),
              ),
            ),
          ],
        );
      },
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

  // TJ미디어 사이트에서 노래 검색을 위한 URL 실행 함수
  void _searchSongNumber(String songName, String singer) async {
    try {
      // 노래 제목을 URL 인코딩하여 검색 URL 생성
      final encodedSongTitle = Uri.encodeComponent(songName);
      final searchUrl = 'https://www.tjmedia.com/song/accompaniment_search?nationType=&strType=0&searchTxt=$encodedSongTitle';

      // URL을 Uri 객체로 변환
      final uri = Uri.parse(searchUrl);

      // 기본 웹 브라우저에서 URL 열기 (수정된 부분)
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,  // 외부 브라우저로 열기
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        // canLaunchUrl이 false를 반환해도 시도해보기
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          print('URL 실행 실패: $e');
          // URL 실행 실패 시 에러 메시지 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('웹 브라우저를 열 수 없습니다.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('검색 오류: $e');
      // 예외 발생 시 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  // 실제 검색 수행 (추후 구현)
  void _performSearch(String songName, String singer) {
    // 여기에 실제 노래방 번호 검색 로직 구현
    // 예: 웹뷰로 TJ미디어나 금영 사이트 연동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$songName - $singer" 검색 기능은 준비 중입니다.'),
        backgroundColor: const Color(0xFF232B3A),
      ),
    );
  }
}
