import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/loading_screen.dart';
import 'services/api_config.dart';
import 'services/parent_dashboard_database.dart';
import 'theme/app_theme.dart';

/// Application entry point integrating LearnCraft app flow with Flame Engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration and initialize ApiConfig
  await ApiConfig.init();
  await ParentDashboardDatabase.instance.initialize();

  // Let Flutter screens adapt naturally to phones, tablets, and desktops.
  // Individual Flame scenes can still choose their own camera composition.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const KnowledgeVerseApp());
}

/// Primary Application Widget housing LearnCraft theme and initial Loading/Auth flow.
class KnowledgeVerseApp extends StatelessWidget {
  const KnowledgeVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KnowledgeVerse - Academy World',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoadingScreen(),
    );
  }
}
