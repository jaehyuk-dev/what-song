import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Clipboard 사용을 위해 추가
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _appVersion = '';
  final String _developerEmail = 'jaehyuk.dev@gmail.com';
  
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  /// 앱 정보를 로드하는 메서드
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'v1.0.0';
      });
    }
  }

  /// 앱 초기화 기능
  Future<void> _resetApp() async {
    // 확인 다이얼로그 표시 - 앱의 다크 테마 스타일에 맞춰 디자인
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A), // 앱 테마와 동일한 다크 배경
          title: const Text(
            '앱 초기화',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '모든 데이터가 삭제됩니다.\n정말로 초기화하시겠습니까?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '초기화',
                style: TextStyle(color: Color(0xFFFF7A5A)), // 앱의 포인트 컬러 사용
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      try {
        // SharedPreferences 초기화
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // 데이터베이스 초기화도 필요시 여기에 추가
        // await DatabaseHelper.instance.deleteDatabase();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('앱이 초기화되었습니다.'),
              backgroundColor: Color(0xFF232B3A), // 앱 테마와 동일한 배경색
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('초기화 중 오류가 발생했습니다.'),
              backgroundColor: Color(0xFF232B3A), // 앱 테마와 동일한 배경색
            ),
          );
        }
      }
    }
  }

  /// URL 실행 메서드
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'URL을 열 수 없습니다: $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크를 여는 중 오류가 발생했습니다: $e'),
            backgroundColor: const Color(0xFF232B3A), // 앱 테마와 동일한 배경색
          ),
        );
      }
    }
  }

  /// 이메일 실행 메서드 - 개선된 버전
  Future<void> _sendEmail() async {
    // 여러 방법으로 문의하기 옵션을 제공하는 다이얼로그 표시
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          title: const Text(
            '문의하기',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '문의 방법을 선택해주세요:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              // 이메일 복사 옵션
              ListTile(
                leading: const Icon(Icons.copy, color: Color(0xFFFF7A5A)),
                title: const Text(
                  '이메일 주소 복사',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _developerEmail,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  _copyEmailToClipboard();
                  Navigator.of(context).pop();
                },
              ),
              const Divider(color: Colors.white24),
              // 이메일 앱으로 열기 옵션
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFFFF7A5A)),
                title: const Text(
                  '이메일 앱으로 열기',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  '기본 이메일 앱에서 작성',
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openEmailApp();
                },
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
          ],
        );
      },
    );
  }

  /// 이메일 주소를 클립보드에 복사
  Future<void> _copyEmailToClipboard() async {
    try {
      // 클립보드에 복사하는 기능 (flutter/services 패키지 사용)
      await Clipboard.setData(ClipboardData(text: _developerEmail));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 주소가 복사되었습니다: $_developerEmail'),
            backgroundColor: const Color(0xFF232B3A),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복사 중 오류가 발생했습니다.'),
            backgroundColor: Color(0xFF232B3A),
          ),
        );
      }
    }
  }

  /// 이메일 앱으로 열기 시도
  Future<void> _openEmailApp() async {
    try {
      final String emailUrl = 'mailto:$_developerEmail?subject=${Uri.encodeComponent('What Song 앱 문의')}&body=${Uri.encodeComponent('안녕하세요.\n\n문의 내용을 입력해 주세요.\n\n---\n앱 버전: $_appVersion\n기기 정보: ${Theme.of(context).platform}')}';
      final Uri uri = Uri.parse(emailUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 이메일 앱을 열 수 없는 경우 대체 방법 안내
        if (mounted) {
          _showEmailNotAvailableDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showEmailNotAvailableDialog();
      }
    }
  }

  /// 이메일 앱을 사용할 수 없을 때 보여주는 다이얼로그
  void _showEmailNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B3A),
          title: const Text(
            '이메일 앱 없음',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '기본 이메일 앱이 설정되어 있지 않습니다.\n\n아래 이메일 주소로 직접 문의해주세요:\n$_developerEmail',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyEmailToClipboard();
              },
              child: const Text(
                '이메일 주소 복사',
                style: TextStyle(color: Color(0xFFFF7A5A)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 앱스토어 리뷰 페이지로 이동
  Future<void> _openAppStore() async {
    // iOS App Store URL (앱 ID를 실제 값으로 변경하세요)
    const String iosUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';
    // Google Play Store URL (패키지명을 실제 값으로 변경하세요)
    const String androidUrl = 'https://play.google.com/store/apps/details?id=com.example.what_song';
    
    // 플랫폼에 따라 다른 URL 사용
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await _launchUrl(iosUrl);
    } else {
      await _launchUrl(androidUrl);
    }
  }

  /// 개인정보처리방침 페이지로 이동
  Future<void> _openPrivacyPolicy() async {
    // 실제 개인정보처리방침 URL로 변경하세요
    const String privacyUrl = 'https://your-website.com/privacy-policy';
    await _launchUrl(privacyUrl);
  }

  /// 설정 아이템 위젯
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showTrailing = true,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF232B3A), // 카드 배경색을 앱 테마에 맞춰 수정
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white70, // 아이콘 색상을 다크 테마에 맞춰 수정
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white, // 제목 텍스트 색상을 흰색으로 수정
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54, // 서브타이틀 색상을 다크 테마에 맞춰 수정
                  fontSize: 14,
                ),
              )
            : null,
        trailing: showTrailing
            ? const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white38, // 화살표 아이콘 색상 수정
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  /// 섹션 헤더 위젯
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70, // 섹션 헤더 색상을 다크 테마에 맞춰 수정
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181E2A), // 앱 메인 배경색과 동일
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // 다크 테마에 맞춰 흰색 텍스트
          ),
        ),
        backgroundColor: const Color(0xFF232B3A), // 앱 내비게이션 바와 동일한 배경색
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // 앱 정보 섹션
            _buildSectionHeader('앱 정보'),
            _buildSettingItem(
              icon: Icons.star_rate,
              title: '앱 평점 남기기',
              subtitle: 'Google Play Store / App Store에서 리뷰를 남겨주세요',
              onTap: _openAppStore,
              iconColor: Colors.amber,
            ),
            
            const SizedBox(height: 16),
            
            // 지원 섹션
            _buildSectionHeader('지원'),
            _buildSettingItem(
              icon: Icons.email,
              title: '문의하기',
              subtitle: '개발자에게 이메일로 문의하세요',
              onTap: _sendEmail,
              iconColor: Colors.blue,
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: '개인정보처리방침',
              subtitle: '개인정보 보호 정책을 확인하세요',
              onTap: _openPrivacyPolicy,
              iconColor: Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // 앱 관리 섹션
            _buildSectionHeader('앱 관리'),
            _buildSettingItem(
              icon: Icons.refresh,
              title: '앱 초기화',
              subtitle: '모든 데이터를 삭제하고 앱을 초기 상태로 되돌립니다',
              onTap: _resetApp,
              iconColor: Colors.red,
            ),
            
            const SizedBox(height: 40),
            
            // 하단 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 앱 버전
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232B3A), // 앱 테마와 동일한 배경색
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12), // 다크 테마에 맞는 테두리 색상
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '앱 버전',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70, // 다크 테마에 맞는 텍스트 색상
                          ),
                        ),
                        Text(
                          _appVersion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // 버전 텍스트를 흰색으로 수정
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 개발자 정보
                  const Text(
                    '개발자 이메일',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54, // 다크 테마에 맞는 텍스트 색상
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _sendEmail,
                    child: Text(
                      _developerEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 저작권 정보
                  const Text(
                    '© 2024 What Song App. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38, // 다크 테마에 맞는 텍스트 색상
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}