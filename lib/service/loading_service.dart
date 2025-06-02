import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/custom_indicator.dart';

class LoadingService {
  static LoadingState? _loadingState;

  // 서비스 초기화 (앱 시작 시 한 번만 호출)
  static void init(BuildContext context) {
    _loadingState = Provider.of<LoadingState>(context, listen: false);
  }

  // 로딩 표시
  static void show() {
    _loadingState?.setLoading(true);
  }

  // 로딩 숨기기
  static void hide() {
    _loadingState?.setLoading(false);
  }

  // Future 작업을 수행하면서 자동으로 로딩 표시/숨기기
  static Future<T> withLoading<T>(Future<T> Function() task) async {
    try {
      show();
      return await task();
    } finally {
      hide();
    }
  }
}