import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'walkthrough_screen.dart';
import 'pin_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if user profile exists
      final userExists = await _dbHelper.checkUserExists();

      if (!mounted) return;

      Widget nextScreen;
      
      if (userExists) {
        // User exists, go to login
        nextScreen = const PINLoginScreen();
      } else {
        // No user exists, show walkthrough
        // (walkthrough_seen flag is irrelevant if no user account exists)
        nextScreen = const WalkthroughScreen();
      }

      // Use FadeTransition for seamless navigation
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      // Default to walkthrough on error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WalkthroughScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF015940),
              Color(0xFF01140E),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
            ),
          ),
        ),
      ),
    );
  }
}