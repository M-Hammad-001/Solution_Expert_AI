// ==================== FILE: first_splash_screen.dart ====================
import 'package:flutter/material.dart';
import 'dart:async';
import 'second_splash_screen.dart';

class FirstSplashScreen extends StatefulWidget {
  const FirstSplashScreen({super.key});

  @override
  State<FirstSplashScreen> createState() => _FirstSplashScreenState();
}

class _FirstSplashScreenState extends State<FirstSplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool showLogo = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller - ONE rotation only
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2 seconds for one rotation
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 6.28319, // 2π - ONE complete 360° rotation
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth start and end
      ),
    );

    // Show logo with delay
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          showLogo = true;
        });
        // Start the rotation animation
        _controller.forward();
      }
    });

    // Navigate to second splash screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const SecondSplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: showLogo
            ? AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            );
          },
          child: Image.asset(
            "Images/Chatbot-Logo.png",
            width: 200,
            height: 200,
          ),
        )
            : const SizedBox(),
      ),
    );
  }
}