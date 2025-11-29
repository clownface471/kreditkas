import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 2)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  credit,
}

@HiveType(typeId: 3)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transactionId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final PaymentMethod method;

  @HiveField(5)
  final String? note;

  Payment({
    required this.id,
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.method,
    this.note,
  });

  Payment copyWith({
    String? id,
    String? transactionId,
    DateTime? date,
    double? amount,
    PaymentMethod? method,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'date': date.toIso8601String(),
      'amount': amount,
      'method': method.name,
      'note': note,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      note: json['note'] as String?,
    );
  }
}
