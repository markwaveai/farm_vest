import 'package:flutter/material.dart';

class DoctorNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double h = size.height;
    double w = size.width;
    double center = w / 2;
    double notchRadius = 42; // Increased for a wider gap
    double depth = 25; // Deeper notch
    double s = 12; // Smoothing factor

    path.lineTo(center - notchRadius - s, 0);

    
    path.cubicTo(
      center - notchRadius,
      0,
      center - notchRadius - (s / 2),
      depth,
      center - notchRadius + s,
      depth,
    );

   
    path.arcToPoint(
      Offset(center + notchRadius - s, depth),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

   
    path.cubicTo(
      center + notchRadius + (s / 2),
      depth,
      center + notchRadius,
      0,
      center + notchRadius + s,
      0,
    );

    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
