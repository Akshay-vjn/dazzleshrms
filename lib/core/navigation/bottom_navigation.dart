import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/announcements/presentation/announcement_screen.dart';
import '../../features/announcements/presentation/employee_announcement_screen.dart';
import '../permissions/permission.dart';
import '../permissions/permission_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  late final AnimationController _controller;

  final _screens = const [
    DashboardScreen(),
    // NotificationScreen(),
    _AnnouncementNavScreen(),
    ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex != index) {
      final distance = (index - _currentIndex).abs();
      setState(() {
        _currentIndex = index;
        _controller.forward(from: 0);
      });
      if (distance > 1) {
        _pageController.jumpToPage(index);
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppTheme.surfaceDark
                : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (theme.brightness == Brightness.dark
                    ? AppTheme.shadowDark
                    : AppTheme.shadowLight).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: "Home",
                isActive: _currentIndex == 0,
                animation: _controller,
                onTap: () => _onTap(0),
                activeColor: AppTheme.navIconSelected,
              ),
              // _NavItem(
              //   icon: Icons.notification_add_outlined,
              //   label: "Notification",
              //   isActive: _currentIndex == 1,
              //   animation: _controller,
              //   onTap: () => _onTap(1),
              //   activeColor: AppTheme.navIconSelected,
              // ),
              _NavItem(
                icon: Icons.newspaper_outlined,
                label: "Announcement",
                isActive: _currentIndex == 1,
                animation: _controller,
                onTap: () => _onTap(1),
                activeColor: AppTheme.navIconSelected,
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: "Profile",
                isActive: _currentIndex == 2,
                animation: _controller,
                onTap: () => _onTap(2),
                activeColor: AppTheme.navIconSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementNavScreen extends ConsumerWidget {
  const _AnnouncementNavScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionProvider);
    if (permissions.contains(Permissions.viewAnnouncements)) {
      return const AnnouncementScreen();
    }
    return const EmployeeAnnouncementScreen();
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Animation<double> animation;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.animation,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.brightness == Brightness.dark
        ? AppTheme.navIconInactiveDark.withOpacity(0.6)
        : AppTheme.navIconInactiveLight.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = isActive ? 1.15 : 1.0;
            final opacity = isActive ? 1.0 : 0.6;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
