import 'package:flutter/material.dart';

class NewSupervisorShell extends StatefulWidget {
  final Widget child;

  const NewSupervisorShell({super.key, required this.child});

  @override
  State<NewSupervisorShell> createState() => _NewSupervisorShellState();
}

class _NewSupervisorShellState extends State<NewSupervisorShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      resizeToAvoidBottomInset: true,
      body: widget.child,
    );
  }
}
