import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../storage/db_service.dart';

class CustomerRepository {
  final DbService _db = DbService.instance;

  Box<Customer> get _box => _db.customers;

  /// Get all customers
  List<Customer> getAll() {
    return _box.values.toList();
  }

  /// Get customer by ID
  Customer? getById(String id) {
    return _box.get(id);
  }

  /// Search customers by name, phone, or email
  List<Customer> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          (c.phone?.toLowerCase().contains(lowerQuery) ?? false) ||
          (c.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Add a new customer
  Future<void> add(Customer customer) async {
    await _box.put(customer.id, customer);
  }

  /// Update an existing customer
  Future<void> update(Customer customer) async {
    await _box.put(customer.id, customer);
  }

  /// Delete a customer
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Check if customer exists
  bool exists(String id) {
    return _box.containsKey(id);
  }

  /// Get customer count
  int get count => _box.length;
}
