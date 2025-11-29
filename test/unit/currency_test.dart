import 'package:flutter_test/flutter_test.dart';
import 'package:kreditkas/core/utils/currency.dart';

void main() {
  group('CurrencyUtils', () {
    test('format currency with symbol', () {
      expect(CurrencyUtils.format(100.50), '\$100.50');
      expect(CurrencyUtils.format(0.99), '\$0.99');
    });

    test('format currency without symbol', () {
      expect(CurrencyUtils.formatNoSymbol(100.50), '100.50');
    });

    test('parse currency string', () {
      expect(CurrencyUtils.parse('\$100.50'), 100.50);
      expect(CurrencyUtils.parse('100.50'), 100.50);
      expect(CurrencyUtils.parse('invalid'), 0.0);
    });

    test('round to 2 decimal places', () {
      expect(CurrencyUtils.round(100.5555), 100.56);
      expect(CurrencyUtils.round(100.5544), 100.55);
    });

    test('calculate percentage', () {
      expect(CurrencyUtils.percentage(100, 10), 10.0);
      expect(CurrencyUtils.percentage(200, 15), 30.0);
    });

    test('calculate with tax', () {
      expect(CurrencyUtils.withTax(100, 10), 110.0);
      expect(CurrencyUtils.withTax(200, 15), 230.0);
    });

    test('calculate with discount', () {
      // Absolute discount
      expect(CurrencyUtils.withDiscount(100, 10, isPercentage: false), 90.0);

      // Percentage discount
      expect(CurrencyUtils.withDiscount(100, 10, isPercentage: true), 90.0);
      expect(CurrencyUtils.withDiscount(200, 15, isPercentage: true), 170.0);
    });

    test('extract tax from inclusive amount', () {
      final tax = CurrencyUtils.extractTax(110, 10);
      expect(tax, closeTo(10.0, 0.01));
    });
  });
}
