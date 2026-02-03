import 'package:farm_vest/features/doctors/widgets/nav_clipper.dart';
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
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipPath(
            clipper: DoctorNavClipper(),
            child: Container(
              height: 70,
              color: AppTheme.darkPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem('assets/icons/rx.png', 'Health', 0),
                  _navItem('assets/icons/injection.png', 'Vaccination', 1),
                  const SizedBox(width: 80),
                  _navItem('assets/icons/swap.png', 'Movement', 2),
                  _navItem('assets/icons/buffalo_icon.png', 'Buffalo', 3),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            child: GestureDetector(
              onTap: () => onTap(4),
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: AppTheme.darkPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    'assets/icons/home.png',
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String assetPath, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: isSelected ? AppTheme.white : Colors.white70,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.white : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
