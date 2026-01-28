import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.green,
        side: const BorderSide(color: Colors.green, width: 1.2),
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.green),
        backgroundColor: Colors.white,
        onSelected: (_) {
          if (onTap != null) onTap!();
        },
      ),
    );
  }
}
