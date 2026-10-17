import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const OpenSkyApp());
}

class OpenSkyApp extends StatelessWidget {
  const OpenSkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpenSky Flight Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}