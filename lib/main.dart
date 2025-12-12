// ==================== FILE: main.dart ====================

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'second_splash_screen.dart';
import 'authentication_screen.dart';
import 'Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solution Expert AI',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      // Set FirstSplashScreen as the initial screen
      initialRoute: '/splash_screen',
      routes: {
        '/': (context) => const FirstSplashScreen(),
        '/second': (context) => const SecondSplashScreen(),
        '/auth': (context) => const AuthenticationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}