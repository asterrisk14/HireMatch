import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../providers/favoruites_provider.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    JobsScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final candidateId = context.read<AuthProvider>().user?.id;
      if (candidateId != null) {
        context.read<FavouritesProvider>().load(candidateId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.sidebarBg,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _navItem(Icons.work_outline, Icons.work, 'Jobs', 1),
                _navItem(Icons.bookmark_border, Icons.bookmark, 'Saved', 2),
                _navItem(Icons.person_outline, Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData outlineIcon, IconData filledIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? filledIcon : outlineIcon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}