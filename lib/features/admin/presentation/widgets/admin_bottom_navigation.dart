import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class AdminBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppTheme.white,
      surfaceTintColor: AppTheme.white,
      elevation: 20,
      shadowColor: AppTheme.black.withValues(alpha: 0.2),
      clipBehavior: Clip.antiAlias,
      height: 70,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.agriculture_outlined, Icons.agriculture, 'Farms', 1),
          _navItem(Icons.bug_report_outlined, Icons.bug_report, 'Tickets', 2),
          const SizedBox(width: 48), // Space for FAB
          _navItem(
            Icons.person_search_outlined,
            Icons.person_search,
            'Staff',
            3,
          ),
          _navItem(Icons.people_alt_outlined, Icons.people_alt, 'Investors', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppTheme.primary
        : AppTheme.slate.withValues(alpha: 0.5);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        overlayColor: WidgetStateProperty.all(
          AppTheme.primary.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 0 : 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
