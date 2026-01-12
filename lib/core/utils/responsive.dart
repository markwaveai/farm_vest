import 'package:flutter/material.dart';

/// Simple responsive helpers used across the dashboard.
/// This file focuses on tablet-only behavior (>= 600px).

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 600;
}

int statsGridCountForWidth(double width) {
  if (width >= 1200) return 3; // large tablet / small desktop
  if (width >= 900) return 3; // medium tablet
  if (width >= 600) return 2; // small tablet
  return 1; // mobile
}

int priorityGridCountForWidth(double width) {
  if (width >= 1200) return 3;
  if (width >= 900) return 2;
  if (width >= 600) return 2;
  return 1;
}

int actionsGridCountForWidth(double width) {
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 3;
  return 1;
}

// Child aspect ratios tuned for tablet layouts
// Child aspect ratios tuned for tablet layouts
double statsChildAspectRatio(double width) {
  // wider cards on tablet -> makes them shorter vertically
  if (width >= 900) return 1.5;
  if (width >= 600) return 1.4;
  return 1.0;
}

double priorityChildAspectRatio(double width) {
  // smaller ratio -> taller cards (more vertical space for buttons)
  if (width >= 1200) return 2.0;
  if (width >= 900) return 1.8;
  if (width >= 600) return 1.7;
  return 1.0;
}

double actionsChildAspectRatio(double width) {
  if (width >= 900) return 1.2;
  if (width >= 600) return 1.1;
  return 1.0;
}
