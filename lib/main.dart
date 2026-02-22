/// MockMate — Entry Point.
///
/// WHY ASYNC MAIN?
/// We need to initialize things before the app starts:
/// 1. Load environment variables (.env file)
/// 2. Set up dependency injection (GetIt)
/// Both of these are async operations, so main() must be async.
///
/// WHY WIDGETSBINDING.ENSUREINITIALIZED()?
/// Some Flutter operations need the framework to be set up first.
/// This call ensures the framework is ready before we do async work.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter framework is initialized before calling platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (most interview apps are portrait).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables from .env file.
  // WHY .env? So we never hardcode sensitive keys (API keys, URLs) in code.
  await dotenv.load(fileName: '.env');

  // Set up all dependencies in GetIt.
  await setupDependencies();

  // Check stored theme preference (default: dark mode for developer aesthetic).
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('app_theme') ?? true;

  // Set system UI overlay style (status bar color).
  SystemChrome.setSystemUIOverlayStyle(
    isDark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );

  runApp(MockMateApp(isDarkMode: isDark));
}

class MockMateApp extends StatefulWidget {
  final bool isDarkMode;
  const MockMateApp({super.key, required this.isDarkMode});

  @override
  State<MockMateApp> createState() => _MockMateAppState();
}

class _MockMateAppState extends State<MockMateApp> {
  late bool _isDarkMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    // Build the router with access to secure storage from DI.
    _router = buildRouter(sl());
  }

  void toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('app_theme', _isDarkMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MockMate',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Navigation
      routerConfig: _router,
    );
  }
}
