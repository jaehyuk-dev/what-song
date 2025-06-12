import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:what_song/screen/main_screen.dart';
import 'package:what_song/service/loading_service.dart';
import 'package:what_song/widget/custom_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Google Mobile Ads SDK 초기화
  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadingState()),
      ],
      child: MaterialApp(
        title: 'What Song',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              LoadingService.init(context);
            });
            return const MainScreen();
          },
        ),
      ),
    );
  }
}
