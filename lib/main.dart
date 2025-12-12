// ==================== FILE: main.dart ====================

import 'package:flutter/material.dart';
import 'api_service.dart'; // ✅ Your Gemini ApiService
import 'splash_screen.dart';
import 'second_splash_screen.dart';
import 'authentication_screen.dart';
import 'Home.dart'; // ✅ Your HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INITIALIZE GEMINI AI (ONE TIME)
  try {
    await ApiService.initGemini();
    print('✅ Gemini AI Ready!');
  } catch (e) {
    print('❌ Gemini init failed: $e');
  }

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
      // ✅ FIXED: Correct initialRoute matching routes map
      initialRoute: '/splash_screen',
      routes: {
        '/splash_screen': (context) => const FirstSplashScreen(),  // ✅ Fixed key
        '/second': (context) => const SecondSplashScreen(),
        '/auth': (context) => const AuthenticationScreen(),
        '/home': (context) => const HomeScreen(),  // ✅ Assuming Home.dart exports HomeScreen
      },
    );
  }
}
