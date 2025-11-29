import 'package:hive/hive.dart';

part 'credit_plan.g.dart';

@HiveType(typeId: 4)
class CreditPlan extends HiveObject {
  @HiveField(0)
  final int tenorMonths; // e.g., 3, 6, 12

  @HiveField(1)
  final double interestRate; // percentage per month or APR

  @HiveField(2)
  final double downPayment; // optional

  CreditPlan({
    required this.tenorMonths,
    required this.interestRate,
    this.downPayment = 0.0,
  });

  /// Calculate monthly payment amount
  /// Uses simple interest calculation
  double monthly(double principal) {
    final i = interestRate / 100.0;
    // Simple interest per month:
    final totalInterest = principal * i * tenorMonths;
    final total = principal + totalInterest - downPayment;
    return total / tenorMonths;
  }

  /// Calculate total amount to be paid
  double totalAmount(double principal) {
    return monthly(principal) * tenorMonths;
  }

  /// Calculate total interest
  double totalInterest(double principal) {
    return totalAmount(principal) - (principal - downPayment);
  }

  CreditPlan copyWith({
    int? tenorMonths,
    double? interestRate,
    double? downPayment,
  }) {
    return CreditPlan(
      tenorMonths: tenorMonths ?? this.tenorMonths,
      interestRate: interestRate ?? this.interestRate,
      downPayment: downPayment ?? this.downPayment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenorMonths': tenorMonths,
      'interestRate': interestRate,
      'downPayment': downPayment,
    };
  }

  factory CreditPlan.fromJson(Map<String, dynamic> json) {
    return CreditPlan(
      tenorMonths: json['tenorMonths'] as int,
      interestRate: (json['interestRate'] as num).toDouble(),
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
