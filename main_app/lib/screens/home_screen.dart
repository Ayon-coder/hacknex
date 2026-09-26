import 'package:flutter/material.dart';
import '../game/ui/hud/bottom_navbar.dart';
import '../theme/app_theme.dart';
import 'knowledge_profile_screen.dart';
import 'rank_progress_screen.dart';
import 'map_list_screen.dart';
import 'settings_screen.dart';
import 'world_archipelago_screen.dart';
import 'world_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initScreens();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initScreens();
  }

  void _initScreens() {
    _screens = [
      WorldScreen(onBack: _handleBackToSubjectSelection),
      MapListScreen(onBackToWorld: _openWorldSection),
      RankProgressScreen(onBackToSubjectSelection: _handleBackToSubjectSelection),
      const KnowledgeProfileScreen(),
      const SettingsScreen(),
    ];
  }

  void _handleBackToSubjectSelection() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) =>
              const WorldArchipelagoScreen(),
          transitionsBuilder: (context, anim1, anim2, child) {
            return FadeTransition(opacity: anim1, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  // Compatibility methods for in-memory closures and active overlays
  // ignore: unused_element
  void _openMap() {
    _handleBackToSubjectSelection();
  }

  // ignore: unused_element
  void _openMapSection() {
    _handleBackToSubjectSelection();
  }
  void _openWorldSection() {
    if (mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          _openWorldSection();
        } else {
          _handleBackToSubjectSelection();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.skyBlue,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Screens Area using IndexedStack to preserve World state
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // Shared themed navigation
            Positioned(
              bottom: 14,
              right: 14,
              child: SafeArea(
                child: BottomNavbarWidget(
                  selectedIndex: _currentIndex,
                  onSelect: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
