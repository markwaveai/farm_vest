import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class CustomCheckboxTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  final EdgeInsetsGeometry? padding;

  const CustomCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.activeColor = AppTheme.successGreen,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    
    final textSize = screenWidth * 0.045;          
    final horizontalPadding = screenWidth * 0.02;  
    final checkboxSize = screenWidth * 0.07;       
    final verticalSpacing = screenWidth * 0.01;    

    return Column(
      children: [
        SizedBox(
          height: checkboxSize * 1.5,
          child: Row(
            children: [
              Transform.scale(
                scale: checkboxSize / 24, 
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: activeColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: horizontalPadding),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    decoration: value ? TextDecoration.lineThrough : null,
                    color: value ? Colors.grey : AppTheme.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: verticalSpacing),
        const Divider(height: 1),
      ],
    );
  }
}

