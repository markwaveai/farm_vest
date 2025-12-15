import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  /// Safe pop for GoRouter
  static void safePopOrNavigate(BuildContext context, {String? fallbackRoute}) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    // No pop possible → navigate to fallback
    if (fallbackRoute != null) {
      context.go(fallbackRoute);
      return;
    }

    // Auto fallback based on URL
    final path = GoRouterState.of(context).uri.toString();

    if (path.contains('customer')) {
      context.go('/customer-dashboard');
    } else if (path.contains('employee') ||
        path.contains('supervisor') ||
        path.contains('doctor') ||
        path.contains('assistant')) {
      context.go('/supervisor-dashboard');
    } else {
      context.go('/user-type-selection');
    }
  }

  static Widget? createSafeBackButton(
    BuildContext context, {
    String? fallbackRoute,
  }) {
    if (context.canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      );
    } else if (fallbackRoute != null) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(fallbackRoute),
      );
    }
    return null;
  }
}
