import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'data/storage/db_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  try {
    await DbService.instance.init();
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
    // Continue anyway - the app will show errors if DB is not working
  }

  // Run the app
  runApp(const KreditKasApp());
}
