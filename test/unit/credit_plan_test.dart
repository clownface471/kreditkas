import 'package:flutter_test/flutter_test.dart';
import 'package:kreditkas/data/models/credit_plan.dart';

void main() {
  group('CreditPlan', () {
    test('calculate monthly payment with simple interest', () {
      final plan = CreditPlan(
        tenorMonths: 12,
        interestRate: 2.0, // 2% per month
        downPayment: 0.0,
      );

      final principal = 1000.0;
      final monthly = plan.monthly(principal);

      // Total interest = 1000 * 0.02 * 12 = 240
      // Total amount = 1000 + 240 = 1240
      // Monthly = 1240 / 12 = 103.33
      expect(monthly, closeTo(103.33, 0.01));
    });

    test('calculate monthly payment with down payment', () {
      final plan = CreditPlan(
        tenorMonths: 6,
        interestRate: 1.5,
        downPayment: 200.0,
      );

      final principal = 1000.0;
      final monthly = plan.monthly(principal);

      // Total interest = 1000 * 0.015 * 6 = 90
      // Total amount = 1000 + 90 - 200 (down payment) = 890
      // Monthly = 890 / 6 = 148.33
      expect(monthly, closeTo(148.33, 0.01));
    });

    test('calculate total amount', () {
      final plan = CreditPlan(
        tenorMonths: 12,
        interestRate: 2.0,
        downPayment: 0.0,
      );

      final principal = 1000.0;
      final totalAmount = plan.totalAmount(principal);

      // Monthly = 103.33, Total = 103.33 * 12 = 1240
      expect(totalAmount, closeTo(1240.0, 0.1));
    });

    test('calculate total interest', () {
      final plan = CreditPlan(
        tenorMonths: 12,
        interestRate: 2.0,
        downPayment: 0.0,
      );

      final principal = 1000.0;
      final totalInterest = plan.totalInterest(principal);

      // Total interest = 1000 * 0.02 * 12 = 240
      expect(totalInterest, closeTo(240.0, 0.01));
    });

    test('toJson and fromJson', () {
      final plan = CreditPlan(
        tenorMonths: 12,
        interestRate: 2.0,
        downPayment: 100.0,
      );

      final json = plan.toJson();
      final restored = CreditPlan.fromJson(json);

      expect(restored.tenorMonths, plan.tenorMonths);
      expect(restored.interestRate, plan.interestRate);
      expect(restored.downPayment, plan.downPayment);
    });
  });
}
