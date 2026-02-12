import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';

class NavItemData {
  final String label;
  final String icon;
  NavItemData(this.label, this.icon);
}

class EmployeeBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserType role;

  const EmployeeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  List<NavItemData> _getRoleItems() {
    switch (role) {
      case UserType.doctor:
        return [
          NavItemData('Health', 'assets/icons/rx.png'),
          NavItemData('Vaccination', 'assets/icons/injection.png'),
          NavItemData('Movement', 'assets/icons/swap.png'),
        ];
      case UserType.supervisor:
        return [
          NavItemData('Milk Entry', 'assets/icons/injection.png'),
          NavItemData('Alerts', 'assets/icons/Notification_icon.png'),
          NavItemData('Stats', 'assets/icons/app_icon.png'),
        ];
      case UserType.farmManager:
        return [
          NavItemData('Onboard', 'assets/icons/new_heat.png'),
          NavItemData('Allocation', 'assets/icons/swap.png'),
          NavItemData('Reports', 'assets/icons/app_icon.png'),
        ];
      case UserType.assistant:
        return [
          NavItemData('Tasks', 'assets/icons/app_icon.png'),
          NavItemData('Monitoring', 'assets/icons/heart.png'),
          NavItemData('Treatments', 'assets/icons/rx.png'),
        ];
      default:
        return [
          NavItemData('Item 1', 'assets/icons/rx.png'),
          NavItemData('Item 2', 'assets/icons/injection.png'),
          NavItemData('Item 3', 'assets/icons/swap.png'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleItems = _getRoleItems();

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      elevation: 20,
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.5)
          : AppTheme.black.withValues(alpha: 0.2),
      clipBehavior: Clip.antiAlias,
      height: 70,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, roleItems[0].icon, roleItems[0].label, 0),
          _navItem(context, roleItems[1].icon, roleItems[1].label, 1),
          const SizedBox(width: 48), // Space for FAB
          _navItem(context, roleItems[2].icon, roleItems[2].label, 2),
          _navItem(context, 'assets/icons/buffalo_icon.png', 'Buffalo', 3),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String assetPath,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? AppTheme.primary
        : theme.hintColor.withValues(alpha: 0.7);

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
              child: Image.asset(
                assetPath,
                width: 24,
                height: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10, // Slightly smaller to accommodate longer labels
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
