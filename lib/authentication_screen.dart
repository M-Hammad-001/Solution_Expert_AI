// ==================== FILE: authentication_screen.dart ====================

import 'package:flutter/material.dart';
import 'dart:async';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String displayText = "Let's Started";

  @override
  void initState() {
    super.initState();

    // Change text after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          displayText = "Let's go";
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
        child: SafeArea(
          child: Column(
            children: [
              // Top section with animated text
              Expanded(
                flex: 5,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          displayText,
                          key: ValueKey<String>(displayText),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom section with buttons
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2D1B3D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Continue with Apple
                      _buildAuthButton(
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        iconColor: Colors.black,
                      ),

                      const SizedBox(height: 12),

                      // Continue with Google
                      _buildAuthButton(
                        onPressed: () {},
                        backgroundColor: const Color(0xFF3D2B4D),
                        foregroundColor: Colors.white,
                        label: 'Continue with Google',
                        customIcon: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sign up with email
                      _buildAuthButton(
                        onPressed: () {},
                        backgroundColor: const Color(0xFF3D2B4D),
                        foregroundColor: Colors.white,
                        icon: Icons.email_outlined,
                        label: 'Sign up with email',
                      ),

                      const SizedBox(height: 12),

                      // Log in button
                      _buildAuthButton(
                        onPressed: () {},
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        label: 'Log in',
                      ),

                      const SizedBox(height: 12),

                      // ⭐ CONTINUE AS GUEST BUTTON (Updated) ⭐
                      _buildAuthButton(
                        onPressed: () {
                          // Navigate to Home Screen
                          Navigator.pushReplacementNamed(context, "/home");
                        },
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        label: 'Continue as a Guest',
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    IconData? icon,
    Widget? customIcon,
    required String label,
    Color? iconColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 24, color: iconColor ?? foregroundColor),
          if (customIcon != null) customIcon,
          if (icon != null || customIcon != null) const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
