import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:instgram_clone/controller/mainpage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        backgroundColor: Colors.white,
        splash: Image.asset(
          'assets/images/iglogo.png',
          // fit: BoxFit.contain,
        ),
        nextScreen: const Mainpage());
  }
}
