import 'package:flutter/material.dart';
enum ButtonVariant { filled, outlined }

class CustomActionButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;

  final ButtonVariant variant;
  final Color color;
  final Color textColor;

  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double height;
  final double? width;
  final Widget? child;
  CustomActionButton({
    super.key,
    this.label,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.color = Colors.green,
    this.textColor = Colors.white,
    this.borderRadius = 8,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.height = 40,
    this.width,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isOutlined = variant == ButtonVariant.outlined;
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: color, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
