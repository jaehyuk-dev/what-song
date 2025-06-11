import 'package:flutter/material.dart';

import '../core/database_helper.dart';

class SearchStoreScreen extends StatefulWidget {
  final bool showFavorites;
  const SearchStoreScreen({super.key, this.showFavorites = false});

  @override
  State<SearchStoreScreen> createState() => _SearchStoreScreenState();
}

class _SearchStoreScreenState extends State<SearchStoreScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _favoriteSongs = [];
  bool _favoritesExpanded = false;

  @override
  void initState() {
    super.initState();
    _favoritesExpanded = widget.showFavorites;
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    try {
      final favorites = await _dbHelper.getFavoriteSongs();
      setState(() {
        _favoriteSongs = favorites;
      });
    } catch (e) {
      print('즐겨찾기 로드 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181E2A),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFavoriteSongsSection(),
          const SizedBox(height: 20),
          const Placeholder(),
        ],
      ),
    );
  }

  Widget _buildFavoriteSongsSection() {
    return ExpansionTile(
      initiallyExpanded: _favoritesExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _favoritesExpanded = expanded;
        });
      },
      backgroundColor: const Color(0xFF232B3A),
      collapsedBackgroundColor: const Color(0xFF232B3A),
      title: const Text(
        '즐겨찾기',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        if (_favoriteSongs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '즐겨찾기한 노래가 없습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        else
          Column(
            children: _favoriteSongs.map((song) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF232B3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song['singer'],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
