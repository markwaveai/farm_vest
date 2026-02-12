import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final String? label;
  final String? initialValue;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? prefixIcon;
  final TextStyle? style;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool showCounter;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    this.label,
    super.key,
    this.hint,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
    this.showCounter = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.style,
    this.onChanged,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      focusNode: focusNode,

      autovalidateMode: autovalidateMode,

      initialValue: controller == null ? initialValue : null,

      enabled: enabled,
      readOnly: readOnly,
      enableInteractiveSelection:
          !readOnly, // Disable selection menu for read-only fields
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: [
        ...?inputFormatters,
        if (textCapitalization == TextCapitalization.characters)
          UpperCaseTextFormatter(),
      ],
      keyboardType: keyboardType,
      validator: validator,
      style: style,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        counter: showCounter ? null : const SizedBox.shrink(),
        // counterText: showCounter ? null : '',
        hintText: hint,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : (!enabled || readOnly ? Colors.grey[200] : Colors.grey[100]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey,
          ),
        ),
      ),
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
