import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String value;
  final IconData icon;
  final Function(String) onChanged;
  final bool isNumber;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const ModernTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.onChanged,
    this.isNumber = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the value changed externally AND it's different from what we show.
    // This prevents clearing the text when a parent rebuilds with the "old" state
    // before the onChanged update has fully propagated.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      final oldSelection = _controller.selection;
      _controller.text = widget.value;
      try {
        _controller.selection = oldSelection;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextFormField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            keyboardType: widget.isNumber
                ? TextInputType.number
                : TextInputType.text,
            inputFormatters: [
              if (widget.isNumber) FilteringTextInputFormatter.digitsOnly,
              if (widget.textCapitalization == TextCapitalization.characters)
                UpperCaseTextFormatter(),
            ],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGrey,
            ),
            decoration: InputDecoration(
              counterText: "",
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppTheme.grey1.withOpacity(0.5),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                widget.icon,
                size: 18,
                color: AppTheme.primary.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
