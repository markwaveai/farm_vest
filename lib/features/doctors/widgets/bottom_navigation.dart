import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class DoctorBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DoctorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      height: 70,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/icons/rx.png', 'Health', 0),
          _navItem('assets/icons/injection.png', 'Vaccination', 1),
          const SizedBox(width: 48), // Space for FAB
          _navItem('assets/icons/swap.png', 'Movement', 2),
          _navItem('assets/icons/buffalo_icon.png', 'Buffalo', 3),
        ],
      ),
    );
  }

  Widget _navItem(String assetPath, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppTheme.primary
        : AppTheme.slate.withOpacity(0.5);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        overlayColor: MaterialStateProperty.all(
          AppTheme.primary.withOpacity(0.1),
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
                    ? AppTheme.primary.withOpacity(0.1)
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
