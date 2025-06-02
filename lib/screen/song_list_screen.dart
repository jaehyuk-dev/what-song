import 'package:flutter/material.dart';

import '../core/database_helper.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _categories = [];
  Map<int, List<Map<String, dynamic>>> _categorySongs = {};
  Map<int, bool> _expandedCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndSongs();
  }

  // 카테고리와 노래 데이터 로드
  Future<void> _loadCategoriesAndSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 카테고리 로드
      List<Map<String, dynamic>> categories = await _dbHelper.getAllCategories();
      
      // 각 카테고리별 노래 로드
      Map<int, List<Map<String, dynamic>>> categorySongs = {};
      for (var category in categories) {
        int categoryId = category['id'];
        List<Map<String, dynamic>> songs = await _dbHelper.getSongsByCategory(categoryId);
        categorySongs[categoryId] = songs;
      }

      setState(() {
        _categories = categories;
        _categorySongs = categorySongs;
        _isLoading = false;
        
        // 모든 카테고리를 기본적으로 접힌 상태로 초기화
        _expandedCategories = {
          for (var category in categories) category['id']: false
        };
      });
    } catch (e) {
      print('데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 즐겨찾기 토글
  Future<void> _toggleFavorite(int songId) async {
    try {
      await _dbHelper.toggleFavorite(songId);
      // 데이터 새로고침
      await _loadCategoriesAndSongs();
    } catch (e) {
      print('즐겨찾기 토글 오류: $e');
    }
  }

  // 카테고리 확장/축소 토글
  void _toggleCategoryExpansion(int categoryId) {
    setState(() {
      _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    });
  }

  // 노래 추가 다이얼로그 표시
  void _showAddSongDialog(int categoryId, String categoryName) {
    final TextEditingController songNameController = TextEditingController();
    final TextEditingController singerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '$categoryName에 노래 추가',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 노래 제목 입력
              TextField(
                controller: songNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '노래 제목',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF7A5A)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF181E2A),
                ),
              ),
              const SizedBox(height: 16),
              // 가수 이름 입력
              TextField(
                controller: singerController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '가수/아티스트',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF7A5A)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF181E2A),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addSong(
                  categoryId: categoryId,
                  songName: songNameController.text.trim(),
                  singer: singerController.text.trim(),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // 노래 번호 검색 기능 (추후 구현)
  void _searchSongNumber(String songName, String singer) {
    // TODO: 노래방 번호 검색 기능 구현 예정
    // 예: 웹뷰로 TJ미디어나 금영 사이트 연동
    // 또는 외부 API 호출
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$songName - $singer" 검색 기능은 준비 중입니다.'),
        backgroundColor: const Color(0xFF232B3A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 노래 삭제 실행
  Future<void> _deleteSong(int songId, String songName) async {
    try {
      await _dbHelper.deleteSong(songId);
      
      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$songName"이(가) 삭제되었습니다.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // 데이터 새로고침
      await _loadCategoriesAndSongs();
    } catch (e) {
      print('노래 삭제 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('노래 삭제 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 노래 추가 실행
  Future<void> _addSong({
    required int categoryId,
    required String songName,
    required String singer,
  }) async {
    // 입력값 검증
    if (songName.isEmpty || singer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('노래 제목과 가수를 모두 입력해주세요.'),
          backgroundColor: Color(0xFF232B3A),
        ),
      );
      return;
    }

    try {
      // 데이터베이스에 노래 추가
      await _dbHelper.insertSong(
        categoryId: categoryId,
        name: songName,
        singer: singer,
        isFavorite: false,
      );

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$songName"이(가) 추가되었습니다!'),
          backgroundColor: const Color(0xFFFF7A5A),
        ),
      );

      // 데이터 새로고침
      await _loadCategoriesAndSongs();
    } catch (e) {
      print('노래 추가 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('노래 추가 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181E2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181E2A),
        elevation: 0,
        title: const Text(
          '저장 목록',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 새로고침
              _loadCategoriesAndSongs();
            },
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFF7A5A),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7A5A),
              ),
            )
          : _categories.isEmpty
              ? _buildEmptyState()
              : _buildCategoryList(),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 카테고리가 없습니다',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '노래를 추가해서 카테고리를 만들어보세요!',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 카테고리 리스트 빌드
  Widget _buildCategoryList() {
    return RefreshIndicator(
      color: const Color(0xFFFF7A5A),
      backgroundColor: const Color(0xFF232B3A),
      onRefresh: _loadCategoriesAndSongs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final categoryId = category['id'] as int;
          final categoryName = category['name'] as String;
          final songs = _categorySongs[categoryId] ?? [];
          final isExpanded = _expandedCategories[categoryId] ?? false;

          return _buildCategoryCard(
            categoryId: categoryId,
            categoryName: categoryName,
            songs: songs,
            isExpanded: isExpanded,
          );
        },
      ),
    );
  }

  // 개별 카테고리 카드 빌드
  Widget _buildCategoryCard({
    required int categoryId,
    required String categoryName,
    required List<Map<String, dynamic>> songs,
    required bool isExpanded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFFFF7A5A).withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 카테고리 헤더
          InkWell(
            onTap: () => _toggleCategoryExpansion(categoryId),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 접힘/열림 아이콘을 왼쪽으로 이동
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded ? const Color(0xFFFF7A5A) : Colors.white70,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 카테고리 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${songs.length}곡',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 노래 추가 버튼 (+ 버튼)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A5A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF7A5A).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _showAddSongDialog(categoryId, categoryName),
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFFFF7A5A),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 노래 리스트 (확장된 경우에만 표시)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSongList(songs),
            crossFadeState: isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  // 노래 리스트 빌드
  Widget _buildSongList(List<Map<String, dynamic>> songs) {
    if (songs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '이 카테고리에는 아직 노래가 없습니다.\n+ 버튼을 눌러 노래를 추가해보세요!',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: songs.map((song) {
        final songId = song['id'] as int;
        final songName = song['name'] as String;
        final singer = song['singer'] as String;
        final isFavorite = (song['is_favorite'] as int) == 1;

        return Dismissible(
          key: Key('song_${songId}'),
          direction: DismissDirection.endToStart, // 왼쪽으로 슬라이드
          confirmDismiss: (direction) async {
            // 삭제 확인 다이얼로그 표시
            bool shouldDelete = false;
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF232B3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    '노래 삭제',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    '"$songName - $singer"\n\n이 노래를 삭제하시겠습니까?\n삭제된 노래는 복구할 수 없습니다.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        shouldDelete = false;
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        shouldDelete = true;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('삭제'),
                    ),
                  ],
                );
              },
            );
            return shouldDelete;
          },
          onDismissed: (direction) async {
            // 삭제 실행
            await _deleteSong(songId, songName);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '삭제',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF181E2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 왼쪽 하트 아이콘
                  InkWell(
                    onTap: () {
                      _toggleFavorite(songId);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isFavorite 
                            ? Colors.red.withOpacity(0.1) 
                            : const Color(0xFF232B3A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white54,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 중앙 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          songName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          singer,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 오른쪽 검색 아이콘
                  InkWell(
                    onTap: () {
                      _searchSongNumber(songName, singer);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A5A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFFFF7A5A),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
