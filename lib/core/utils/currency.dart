import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _noSymbolFormatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

  /// Format amount as currency with symbol
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format amount as currency without symbol
  static String formatNoSymbol(double amount) {
    return _noSymbolFormatter.format(amount).trim();
  }

  /// Parse currency string to double
  static double parse(String value) {
    try {
      final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  /// Round to 2 decimal places
  static double round(double value) {
    return (value * 100).round() / 100;
  }

  /// Calculate percentage
  static double percentage(double amount, double percent) {
    return round(amount * percent / 100);
  }

  /// Calculate amount with tax
  static double withTax(double amount, double taxRate) {
    return round(amount + percentage(amount, taxRate));
  }

  /// Calculate amount with discount
  static double withDiscount(double amount, double discount, {bool isPercentage = false}) {
    if (isPercentage) {
      return round(amount - percentage(amount, discount));
    }
    return round(amount - discount);
  }

  /// Extract tax from inclusive amount
  static double extractTax(double inclusiveAmount, double taxRate) {
    return round(inclusiveAmount - (inclusiveAmount / (1 + taxRate / 100)));
  }
}
