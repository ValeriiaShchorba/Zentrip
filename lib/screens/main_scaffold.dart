import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/language/language_provider.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'visited_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const VisitedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: const Icon(Icons.explore),
              label: language == 'TR' ? "Keşfet" : "Explore",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite),
              label: language == 'TR' ? "Favoriler" : "Favorites",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.task_alt),
              activeIcon: const Icon(Icons.check_circle),
              label: language == 'TR' ? "Gidilenler" : "Visited",
            ),
          ],
        ),
      ),
    );
  }
}
