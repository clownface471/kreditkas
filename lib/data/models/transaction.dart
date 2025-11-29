import 'package:hive/hive.dart';
import 'payment.dart';
import 'credit_plan.dart';

part 'transaction.g.dart';

@HiveType(typeId: 5)
class TransactionItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int qty;

  @HiveField(3)
  double unitPrice;

  double get lineTotal => unitPrice * qty;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  TransactionItem copyWith({
    String? productId,
    String? name,
    int? qty,
    double? unitPrice,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'qty': qty,
      'unitPrice': unitPrice,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      qty: json['qty'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}

@HiveType(typeId: 6)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? customerId;

  @HiveField(3)
  final List<TransactionItem> items;

  @HiveField(4)
  final double subtotal;

  @HiveField(5)
  final double discount;

  @HiveField(6)
  final double tax;

  @HiveField(7)
  final double total;

  @HiveField(8)
  final PaymentMethod method;

  @HiveField(9)
  final CreditPlan? creditPlan; // present if method == credit

  @HiveField(10)
  final double paid; // initial payment

  @HiveField(11)
  final double change;

  @HiveField(12)
  double remainingBalance; // for credit tracking

  Transaction({
    required this.id,
    required this.date,
    this.customerId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.method,
    this.creditPlan,
    required this.paid,
    required this.change,
    double? remainingBalance,
  }) : remainingBalance = remainingBalance ?? (method == PaymentMethod.credit ? total - paid : 0.0);

  Transaction copyWith({
    String? id,
    DateTime? date,
    String? customerId,
    List<TransactionItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    PaymentMethod? method,
    CreditPlan? creditPlan,
    double? paid,
    double? change,
    double? remainingBalance,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      method: method ?? this.method,
      creditPlan: creditPlan ?? this.creditPlan,
      paid: paid ?? this.paid,
      change: change ?? this.change,
      remainingBalance: remainingBalance ?? this.remainingBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'method': method.name,
      'creditPlan': creditPlan?.toJson(),
      'paid': paid,
      'change': change,
      'remainingBalance': remainingBalance,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      customerId: json['customerId'] as String?,
      items: (json['items'] as List)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      creditPlan: json['creditPlan'] != null
          ? CreditPlan.fromJson(json['creditPlan'] as Map<String, dynamic>)
          : null,
      paid: (json['paid'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble(),
    );
  }
}
