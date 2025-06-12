import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 배너 광고를 표시하는 위젯
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  // 배너 광고 로드 함수
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // 테스트용 광고 ID 사용 (실제 배포 시에는 실제 광고 ID로 변경 필요)
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트용 배너 광고 ID
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('배너 광고 로드 성공');
        },
        onAdFailedToLoad: (ad, error) {
          print('배너 광고 로드 실패: $error');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (ad) {
          print('배너 광고 열림');
        },
        onAdClosed: (ad) {
          print('배너 광고 닫힘');
        },
        onAdClicked: (ad) {
          print('배너 광고 클릭됨');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 광고 객체 해제
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 로드되지 않았으면 빈 공간 반환
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}