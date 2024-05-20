import 'package:collective_rider/global/global.dart';
import 'package:collective_rider/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            firebaseAuth.signOut();
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => SplashScreen()));
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
