import 'package:intl/intl.dart';

extension NumberFormatter on num {
  String formatIndianDecimal() {
    final format = NumberFormat.decimalPattern('en_IN');
    return format.format(this);
  }

  String formatRupee() {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(this);
  }
}
