import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPouch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Updated seed color to match your gradient's primary green
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF015940)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}