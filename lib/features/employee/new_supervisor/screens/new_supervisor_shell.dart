import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSupervisorShell extends StatefulWidget {
  final Widget child;

  const NewSupervisorShell({super.key, required this.child});

  @override
  State<NewSupervisorShell> createState() => _NewSupervisorShellState();
}

class _NewSupervisorShellState extends State<NewSupervisorShell> {
  int _currentIndex = 0;

  int? _indexForLocation(String location) {
   

    if (location.startsWith('/supervisor-dashboard')) return 0;
    if (location.startsWith('/new-supervisor/buffalo')) return 1;
    if (location.startsWith('/new-supervisor/alerts')) return 2;
    if (location.startsWith('/new-supervisor/stats')) return 3;
    if (location.startsWith('/new-supervisor/more')) return 4;
    return null;
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        context.go('/supervisor-dashboard');
        break;
      case 1:
        context.go('/new-supervisor/buffalo');
        break;
      case 2:
        context.go('/new-supervisor/alerts');
        break;
      case 3:
        context.go('/new-supervisor/stats');
        break;
      case 4:
        context.go('/new-supervisor/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final idx = _indexForLocation(location);
    if (idx != null && idx != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentIndex = idx);
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widget.child,
      bottomNavigationBar: _NewSupervisorBottomNav(
        selectedIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NewSupervisorBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NewSupervisorBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.pets,
      Icons.notifications,
      Icons.bar_chart,
      Icons.more_horiz,
    ];

    final labels = [
      'Home',
      'Buffalo',
      'Alerts',
      'Stats',
      'More',
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isActive = selectedIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: isActive ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? Colors.blue : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: isActive ? 18 : 0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
