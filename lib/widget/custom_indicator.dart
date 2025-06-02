import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomIndicator extends StatefulWidget {
  const CustomIndicator({super.key});

  @override
  State<CustomIndicator> createState() => _CustomIndicatorState();
}

class _CustomIndicatorState extends State<CustomIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 무한 반복
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
        indicatorType: Indicator.orbit, /// Required, The loading type of the widget
        colors: const [Colors.white],       /// Optional, The color collections
        strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
        backgroundColor: Colors.transparent,      /// Optional, Background of the widget
        pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
    );
  }
}

class LoadingState extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}