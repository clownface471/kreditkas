import 'package:hive/hive.dart';

part 'store_profile.g.dart';

@HiveType(typeId: 7)
class StoreProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? logoPath;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final double defaultTaxRate; // percentage

  @HiveField(6)
  final bool taxInclusive;

  @HiveField(7)
  final double defaultDiscount;

  @HiveField(8)
  final bool allowOversell;

  @HiveField(9)
  final bool requireCustomerForCredit;

  @HiveField(10)
  final bool autoOpenReceiptPreview;

  @HiveField(11)
  final String? footerNote;

  @HiveField(12)
  final String? returnPolicy;

  StoreProfile({
    required this.name,
    this.logoPath,
    this.address,
    this.phone,
    this.email,
    this.defaultTaxRate = 0.0,
    this.taxInclusive = false,
    this.defaultDiscount = 0.0,
    this.allowOversell = false,
    this.requireCustomerForCredit = true,
    this.autoOpenReceiptPreview = true,
    this.footerNote,
    this.returnPolicy,
  });

  StoreProfile copyWith({
    String? name,
    String? logoPath,
    String? address,
    String? phone,
    String? email,
    double? defaultTaxRate,
    bool? taxInclusive,
    double? defaultDiscount,
    bool? allowOversell,
    bool? requireCustomerForCredit,
    bool? autoOpenReceiptPreview,
    String? footerNote,
    String? returnPolicy,
  }) {
    return StoreProfile(
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      defaultDiscount: defaultDiscount ?? this.defaultDiscount,
      allowOversell: allowOversell ?? this.allowOversell,
      requireCustomerForCredit: requireCustomerForCredit ?? this.requireCustomerForCredit,
      autoOpenReceiptPreview: autoOpenReceiptPreview ?? this.autoOpenReceiptPreview,
      footerNote: footerNote ?? this.footerNote,
      returnPolicy: returnPolicy ?? this.returnPolicy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoPath': logoPath,
      'address': address,
      'phone': phone,
      'email': email,
      'defaultTaxRate': defaultTaxRate,
      'taxInclusive': taxInclusive,
      'defaultDiscount': defaultDiscount,
      'allowOversell': allowOversell,
      'requireCustomerForCredit': requireCustomerForCredit,
      'autoOpenReceiptPreview': autoOpenReceiptPreview,
      'footerNote': footerNote,
      'returnPolicy': returnPolicy,
    };
  }

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      name: json['name'] as String,
      logoPath: json['logoPath'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      defaultTaxRate: (json['defaultTaxRate'] as num?)?.toDouble() ?? 0.0,
      taxInclusive: json['taxInclusive'] as bool? ?? false,
      defaultDiscount: (json['defaultDiscount'] as num?)?.toDouble() ?? 0.0,
      allowOversell: json['allowOversell'] as bool? ?? false,
      requireCustomerForCredit: json['requireCustomerForCredit'] as bool? ?? true,
      autoOpenReceiptPreview: json['autoOpenReceiptPreview'] as bool? ?? true,
      footerNote: json['footerNote'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
    );
  }

  static StoreProfile defaultProfile() {
    return StoreProfile(
      name: 'My Store',
      defaultTaxRate: 10.0,
      taxInclusive: false,
      defaultDiscount: 0.0,
      allowOversell: false,
      requireCustomerForCredit: true,
      autoOpenReceiptPreview: true,
      footerNote: 'Thank you for your business!',
    );
  }
}
