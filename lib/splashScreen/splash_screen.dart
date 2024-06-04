import 'dart:async';
import 'package:collective_rider/assistant/assistant_methods.dart';
import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/screens/login_screen.dart';
import 'package:collective_rider/screens/main_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer() {
    Timer(
        const Duration(
          seconds: 3,
        ), () {
      if (firebaseAuth.currentUser != null) {
        firebaseAuth.currentUser != null
            ? AssistantMethods.readCurrentOnlineUserInfo()
            : null;
        if (!mounted) return;

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        if (!mounted) return;

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Collective Rider',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
