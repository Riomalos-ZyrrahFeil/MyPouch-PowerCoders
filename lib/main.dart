import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  await NotificationService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _setupCheckFuture;

  @override
  void initState() {
    super.initState();
    _setupCheckFuture = _checkIfSetupComplete();
  }

  Future<bool> _checkIfSetupComplete() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.userProfileExists();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPouch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
      home: FutureBuilder<bool>(
        future: _setupCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          // Always show splash screen first - it will handle navigation logic
          return const SplashScreen();
        },
      ),
    );
  }
}