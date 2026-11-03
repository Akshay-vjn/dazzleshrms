import '../app_theme/glass_surface.dart';
import '../app_theme/app_visuals.dart';
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

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final _screens = const [
    DashboardScreen(),
    // NotificationScreen(),
    _AnnouncementNavScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex != index) {
      final distance = (index - _currentIndex).abs();
      setState(() {
        _currentIndex = index;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70 + (MediaQuery.textScalerOf(context).scale(11) - 11) * 2,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),

          child: GlassSurface(
            radius: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: "Home",
                  isActive: _currentIndex == 0,
                  onTap: () => _onTap(0),
                  activeColor: AppVisuals.of(context).accent,
                ),
                // _NavItem(
                //   icon: Icons.notification_add_outlined,
                //   label: "Notification",
                //   isActive: _currentIndex == 1,
                //   animation: _controller,
                //   onTap: () => _onTap(1),
                //   activeColor: AppVisuals.of(context).accent,
                // ),
                _NavItem(
                  icon: Icons.newspaper_outlined,
                  label: "Announcement",
                  isActive: _currentIndex == 1,
                  onTap: () => _onTap(1),
                  activeColor: AppVisuals.of(context).accent,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: "Profile",
                  isActive: _currentIndex == 2,
                  onTap: () => _onTap(2),
                  activeColor: AppVisuals.of(context).accent,
                ),
              ],
            ),
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
  final VoidCallback onTap;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.brightness == Brightness.dark
        ? AppTheme.navIconInactiveDark
        : AppTheme.navIconInactiveLight;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? AppVisuals.of(context).accentSurface.withValues(alpha: .7)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
