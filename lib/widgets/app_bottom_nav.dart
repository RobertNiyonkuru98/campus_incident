import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Three-tab bar.
///
/// Material's NavigationBar owns its own metrics, so icon size, label height and
/// touch targets line up without hand-tuning flex widths.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onHome,
    required this.onReports,
    required this.onProfile,
  });

  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onReports;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      height: 66,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.10),
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            onHome();
            break;
          case 1:
            onReports();
            break;
          case 2:
            onProfile();
            break;
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description, color: AppColors.primary),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
