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
        selectedColor: Theme.of(context).primaryColor,
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.2),
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Theme.of(context).cardColor,
        onSelected: (_) {
          if (onTap != null) onTap!();
        },
      ),
    );
  }
}
