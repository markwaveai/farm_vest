import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
class CustomCurvedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CurvedNavigationBarItem> items;

  CustomCurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Curved background
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: CurvedNavigationPainter(),
          ),
          // Navigation items
          Center(
            heightFactor: 0.1,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.videocam, color: Colors.white, size: 28),
                onPressed: () => onTap(2), // Middle item index
              ),
            ),
          ),
          // Other navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              // Skip middle item as it's handled separately
              if (index == 2) {
                return SizedBox(width: 60); // Space for middle button
              }

              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AppTheme.primary : Colors.grey[600],
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class CurvedNavigationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo((size.width / 2) - 35, 0);

    // First curve
    path.quadraticBezierTo((size.width / 2) - 30, 0, (size.width / 2) - 30, 5);

    // Left curve
    path.arcToPoint(
      Offset((size.width / 2) - 15, 20),
      radius: Radius.circular(20),
      clockwise: false,
    );

    // Top curve
    path.arcToPoint(
      Offset((size.width / 2) + 15, 20),
      radius: Radius.circular(30),
    );

    // Right curve
    path.arcToPoint(
      Offset((size.width / 2) + 30, 5),
      radius: Radius.circular(20),
      clockwise: false,
    );

    // Last curve
    path.quadraticBezierTo((size.width / 2) + 30, 0, (size.width / 2) + 35, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedNavigationBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  CurvedNavigationBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
