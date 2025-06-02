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
  
  // 카테고리 관리 모드 상태
  bool _isManageMode = false;
  Set<int> _selectedCategories = {};
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndSongs();
  }

  // 일반 모드 AppBar
  Widget _buildNormalAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '저장 목록',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: _toggleManageMode,
          icon: const Icon(
            Icons.menu,
            color: Color(0xFFFF7A5A),
          ),
        ),
      ],
    );
  }

  // 관리 모드 AppBar
  Widget _buildManageModeAppBar() {
    return Row(
      children: [
        // 전체 선택 체크박스
        Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: _isAllSelected,
                onChanged: (value) => _toggleSelectAll(),
                activeColor: const Color(0xFFFF7A5A),
                checkColor: Colors.white,
              ),
            ),
            const Text(
              '전체선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // 삭제 아이콘 버튼
        IconButton(
          onPressed: _selectedCategories.isNotEmpty ? _deleteSelectedCategories : null,
          icon: Icon(
            Icons.delete_outline,
            color: _selectedCategories.isNotEmpty ? Colors.red : Colors.white38,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        const Spacer(),
        // 추가 버튼
        ElevatedButton(
          onPressed: _showAddCategoryDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A5A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('+ 카테고리 추가'),
        ),
        const SizedBox(width: 8),
        // 취소 버튼
        TextButton(
          onPressed: _toggleManageMode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

// SongListScreen 클래스 내부
// 1. _loadCategoriesAndSongs 메서드 수정본
  Future<void> _loadCategoriesAndSongs({ Map<int, bool>? preserveExpanded }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // [1] 모든 카테고리 로드
      List<Map<String, dynamic>> categories = await _dbHelper.getAllCategories();

      // [2] 카테고리별로 노래 로드
      Map<int, List<Map<String, dynamic>>> categorySongs = {};
      for (var category in categories) {
        int categoryId = category['id'];
        List<Map<String, dynamic>> songs =
        await _dbHelper.getSongsByCategory(categoryId);
        categorySongs[categoryId] = songs;
      }

      setState(() {
        _categories = categories;
        _categorySongs = categorySongs;
        _isLoading = false;

        // [3] 확장 상태 보존 로직
        _expandedCategories = {
          for (var category in categories)
            category['id']: (preserveExpanded?[category['id']] == true)
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
// 2. _toggleFavorite 메서드 수정본
  Future<void> _toggleFavorite(int songId) async {
    try {
      // [1] 현재 확장 상태 복사본 생성
      final previousExpanded = Map<int, bool>.from(_expandedCategories);

      // [2] DB에 is_favorite 토글
      await _dbHelper.toggleFavorite(songId);

      // [3] 전체 데이터를 다시 불러오되, 확장 상태 보존
      await _loadCategoriesAndSongs(preserveExpanded: previousExpanded);
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

  // 카테고리 관리 모드 토글
  void _toggleManageMode() {
    setState(() {
      _isManageMode = !_isManageMode;
      if (!_isManageMode) {
        // 관리 모드 종료 시 선택 상태 초기화
        _selectedCategories.clear();
        _isAllSelected = false;
      }
    });
  }

  // 전체 선택 토글
  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedCategories.clear();
      } else {
        _selectedCategories.addAll(_categories.map((cat) => cat['id'] as int));
      }
      _isAllSelected = !_isAllSelected;
    });
  }

  // 개별 카테고리 선택 토글
  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
      _isAllSelected = _selectedCategories.length == _categories.length;
    });
  }

  // 선택된 카테고리 삭제
  void _deleteSelectedCategories() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제할 카테고리를 선택해주세요.'),
          backgroundColor: Color(0xFF232B3A),
        ),
      );
      return;
    }

    // 선택된 카테고리에 포함된 총 노래 수 계산
    int totalSongs = 0;
    List<String> categoryNames = [];
    
    for (int categoryId in _selectedCategories) {
      var category = _categories.firstWhere((cat) => cat['id'] == categoryId);
      categoryNames.add(category['name']);
      totalSongs += (_categorySongs[categoryId]?.length ?? 0);
    }

    // 삭제 확인 다이얼로그
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '카테고리 삭제 경고',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '선택된 카테고리: ${_selectedCategories.length}개',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                categoryNames.join(', '),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '경고',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '카테고리와 함께 포함된 모든 노래($totalSongs곡)가 영구적으로 삭제됩니다.',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '삭제된 데이터는 복구할 수 없습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldDelete) {
      try {
        // 선택된 카테고리 삭제
        for (int categoryId in _selectedCategories) {
          await _dbHelper.deleteCategory(categoryId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedCategories.length}개 카테고리가 삭제되었습니다.'),
            backgroundColor: Colors.red,
          ),
        );

        // 관리 모드 종료 및 데이터 새로고침
        _toggleManageMode();
        await _loadCategoriesAndSongs();
      } catch (e) {
        print('카테고리 삭제 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카테고리 삭제 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 카테고리 추가 다이얼로그
  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '새 카테고리 추가',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: categoryNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '카테고리 이름',
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
            autofocus: true,
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
                _addCategory(categoryNameController.text.trim());
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A5A),
                foregroundColor: Colors.white,
              ),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // 카테고리 추가 실행
  Future<void> _addCategory(String categoryName) async {
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리 이름을 입력해주세요.'),
          backgroundColor: Color(0xFF232B3A),
        ),
      );
      return;
    }

    try {
      await _dbHelper.insertCategory(categoryName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$categoryName" 카테고리가 추가되었습니다!'),
          backgroundColor: const Color(0xFFFF7A5A),
        ),
      );

      await _loadCategoriesAndSongs();
    } catch (e) {
      print('카테고리 추가 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리 추가 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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
// 3. _deleteSong 메서드 수정본
  Future<void> _deleteSong(int songId, String songName) async {
    try {
      // [1] 현재 확장 상태 복사본 생성
      final previousExpanded = Map<int, bool>.from(_expandedCategories);

      // [2] DB에서 노래 삭제
      await _dbHelper.deleteSong(songId);

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$songName"이(가) 삭제되었습니다.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      // [3] 전체 데이터를 다시 불러오되, 확장 상태 보존
      await _loadCategoriesAndSongs(preserveExpanded: previousExpanded);
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
// 4. _addSong 메서드 수정본
  Future<void> _addSong({
    required int categoryId,
    required String songName,
    required String singer,
  }) async {
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
      // [1] 현재 확장 상태 복사본 생성
      final previousExpanded = Map<int, bool>.from(_expandedCategories);

      // [2] DB에 노래 추가
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

      // [3] 전체 데이터를 다시 불러오되, 확장 상태 보존
      await _loadCategoriesAndSongs(preserveExpanded: previousExpanded);
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
        automaticallyImplyLeading: false,
        toolbarHeight: 56, // 고정 높이
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _isManageMode ? _buildManageModeAppBar() : _buildNormalAppBar(),
        ),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            '아직 카테고리가 없습니다',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
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
    return ListView.builder(
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
            onTap: _isManageMode 
                ? () => _toggleCategorySelection(categoryId)
                : () => _toggleCategoryExpansion(categoryId),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 관리 모드일 때 체크박스 표시, 일반 모드일 때 접힘/열림 아이콘
                  _isManageMode 
                    ? Row(
                        children: [
                          Checkbox(
                            value: _selectedCategories.contains(categoryId),
                            onChanged: (value) => _toggleCategorySelection(categoryId),
                            activeColor: const Color(0xFFFF7A5A),
                            checkColor: Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                      )
                    : Row(
                        children: [
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
                        ],
                      ),
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
                  // 노래 추가 버튼 (+ 버튼) - 관리 모드가 아닐 때만 표시
                  if (!_isManageMode)
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
