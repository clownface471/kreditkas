import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction.dart';
import '../../data/models/product.dart';
import '../../data/models/customer.dart';
import '../../data/models/payment.dart';
import '../../data/models/credit_plan.dart';
import '../../data/models/store_profile.dart';
import '../../data/repositories/transaction_repo.dart';
import '../../data/repositories/product_repo.dart';
import '../../data/repositories/customer_repo.dart';
import '../../data/repositories/settings_repo.dart';
import '../../services/receipt_service.dart';
import '../../services/print_service.dart';
import '../../core/utils/currency.dart';

class SalesController extends GetxController {
  final TransactionRepository _transactionRepo;
  final ProductRepository _productRepo;
  final CustomerRepository _customerRepo;
  final SettingsRepository _settingsRepo;
  final ReceiptService _receiptService;
  final PrintService _printService;

  SalesController(
    this._transactionRepo,
    this._productRepo,
    this._customerRepo,
    this._settingsRepo,
    this._receiptService,
    this._printService,
  );

  // Cart state
  final cart = <TransactionItem>[].obs;
  final discount = 0.0.obs;
  final discountIsPercentage = false.obs;
  final tax = 0.0.obs;
  final taxIsInclusive = false.obs;

  // Payment state
  final paymentMethod = PaymentMethod.cash.obs;
  final selectedCreditPlan = Rx<CreditPlan?>(null);
  final selectedCustomer = Rx<Customer?>(null);
  final amountPaid = 0.0.obs;

  // Computed values
  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get discountAmount {
    if (discountIsPercentage.value) {
      return CurrencyUtils.percentage(subtotal, discount.value);
    }
    return discount.value;
  }

  double get taxAmount {
    final base = subtotal - discountAmount;
    if (taxIsInclusive.value) {
      return CurrencyUtils.extractTax(base, tax.value);
    }
    return CurrencyUtils.percentage(base, tax.value);
  }

  double get total {
    final base = subtotal - discountAmount;
    if (taxIsInclusive.value) {
      return base;
    }
    return base + taxAmount;
  }

  double get change {
    if (paymentMethod.value == PaymentMethod.cash) {
      final diff = amountPaid.value - total;
      return diff > 0 ? diff : 0.0;
    }
    return 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDefaults();
  }

  void _loadDefaults() {
    final profile = _settingsRepo.getStoreProfile();
    tax.value = profile.defaultTaxRate;
    taxIsInclusive.value = profile.taxInclusive;
    discount.value = profile.defaultDiscount;
  }

  /// Add product to cart
  void addToCart(Product product, {int qty = 1}) {
    // Check if product already in cart
    final existingIndex = cart.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Update quantity
      final existing = cart[existingIndex];
      existing.qty += qty;
      cart.refresh();
    } else {
      // Add new item
      final item = TransactionItem(
        productId: product.id,
        name: product.name,
        qty: qty,
        unitPrice: product.price,
      );
      cart.add(item);
    }
  }

  /// Remove item from cart
  void removeFromCart(String productId) {
    cart.removeWhere((item) => item.productId == productId);
  }

  /// Update item quantity
  void setQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = cart.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      cart[index].qty = qty;
      cart.refresh();
    }
  }

  /// Clear cart
  void clearCart() {
    cart.clear();
    selectedCustomer.value = null;
    selectedCreditPlan.value = null;
    amountPaid.value = 0.0;
  }

  /// Set payment method
  void setPaymentMethod(PaymentMethod method) {
    paymentMethod.value = method;

    if (method == PaymentMethod.cash) {
      selectedCreditPlan.value = null;
    } else {
      // Load default credit plan
      final plans = _settingsRepo.getDefaultCreditPlans();
      if (plans.isNotEmpty) {
        selectedCreditPlan.value = plans.first;
      }
    }
  }

  /// Set credit plan
  void setCreditPlan(CreditPlan? plan) {
    selectedCreditPlan.value = plan;
  }

  /// Set customer
  void setCustomer(Customer? customer) {
    selectedCustomer.value = customer;
  }

  /// Set discount
  void setDiscount(double value, {bool isPercentage = false}) {
    discount.value = value;
    discountIsPercentage.value = isPercentage;
  }

  /// Validate checkout
  String? validateCheckout() {
    if (cart.isEmpty) {
      return 'Cart is empty';
    }

    // Check stock availability
    for (final item in cart) {
      if (!_productRepo.hasStock(item.productId, item.qty)) {
        return 'Insufficient stock for ${item.name}';
      }
    }

    // Credit validation
    if (paymentMethod.value == PaymentMethod.credit) {
      final profile = _settingsRepo.getStoreProfile();
      if (profile.requireCustomerForCredit && selectedCustomer.value == null) {
        return 'Customer required for credit transactions';
      }
      if (selectedCreditPlan.value == null) {
        return 'Please select a credit plan';
      }
    }

    // Cash validation
    if (paymentMethod.value == PaymentMethod.cash) {
      if (amountPaid.value < total) {
        return 'Insufficient payment amount';
      }
    }

    return null;
  }

  /// Checkout and create transaction
  Future<Transaction?> checkout() async {
    final error = validateCheckout();
    if (error != null) {
      Get.snackbar('Error', error);
      return null;
    }

    try {
      // Create transaction
      final transaction = Transaction(
        id: const Uuid().v4(),
        date: DateTime.now(),
        customerId: selectedCustomer.value?.id,
        items: cart.toList(),
        subtotal: subtotal,
        discount: discountAmount,
        tax: taxAmount,
        total: total,
        method: paymentMethod.value,
        creditPlan: selectedCreditPlan.value,
        paid: paymentMethod.value == PaymentMethod.cash ? amountPaid.value : 0.0,
        change: change,
      );

      // Save transaction
      await _transactionRepo.add(transaction);

      // Update stock
      for (final item in cart) {
        await _productRepo.decrementStock(item.productId, item.qty);
      }

      // Generate and print receipt
      final profile = _settingsRepo.getStoreProfile();
      if (profile.autoOpenReceiptPreview) {
        await printReceipt(transaction);
      }

      // Clear cart
      clearCart();

      Get.snackbar('Success', 'Transaction completed successfully');
      return transaction;
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete transaction: $e');
      return null;
    }
  }

  /// Print receipt
  Future<void> printReceipt(Transaction transaction) async {
    try {
      final profile = _settingsRepo.getStoreProfile();
      final customerName = selectedCustomer.value?.name;

      final pdfBytes = await _receiptService.buildReceipt(
        transaction,
        profile,
        customerName: customerName,
      );

      await _printService.printPdf(pdfBytes, filename: 'receipt_${transaction.id}.pdf');
    } catch (e) {
      Get.snackbar('Error', 'Failed to print receipt: $e');
    }
  }

  /// Void a transaction
  Future<void> voidTransaction(String transactionId) async {
    try {
      final transaction = _transactionRepo.getById(transactionId);
      if (transaction == null) {
        Get.snackbar('Error', 'Transaction not found');
        return;
      }

      // Restore stock
      for (final item in transaction.items) {
        await _productRepo.incrementStock(item.productId, item.qty);
      }

      // Delete transaction
      await _transactionRepo.delete(transactionId);

      Get.snackbar('Success', 'Transaction voided successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to void transaction: $e');
    }
  }
}
