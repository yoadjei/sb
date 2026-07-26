import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class DigitalSportsScoreboardApp extends StatelessWidget {
  const DigitalSportsScoreboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Sports Scoreboard',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
