// ==================== FILE: second_splash_screen.dart ====================

import 'package:flutter/material.dart';
import 'dart:async';
import 'authentication_screen.dart';

class SecondSplashScreen extends StatefulWidget {
  const SecondSplashScreen({super.key});

  @override
  State<SecondSplashScreen> createState() => _SecondSplashScreenState();
}

class _SecondSplashScreenState extends State<SecondSplashScreen> {

  String fullText = "Solution Expert AI";
  String animatedText = "";
  int textIndex = 0;

  @override
  void initState() {
    super.initState();

    // Start typing effect after small delay
    Timer(const Duration(milliseconds: 300), () {
      startTypingAnimation();
    });
  }

  // TYPING ANIMATION FUNCTION
  void startTypingAnimation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (textIndex < fullText.length) {
        setState(() {
          animatedText += fullText[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();

        // Navigate to authentication screen after typing completes
        Timer(const Duration(milliseconds: 700), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthenticationScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD946EF),
              Color(0xFF9333EA),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: Stack(
          children: [
            // CENTERED LOGO - Same position as first screen
            Center(
              child: Image.asset(
                "Images/Chatbot-Logo.png",
                width: 200,
                height: 200,
              ),
            ),

            // TEXT POSITIONED BELOW LOGO
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 220), // Logo height (200) + spacing (20)
                child: Text(
                  animatedText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black38,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}