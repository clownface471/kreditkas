class Validators {
  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate phone number (basic)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value) || value.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate numeric value
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }

    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;

    final num = double.parse(value!);
    if (num < 0) {
      return '${fieldName ?? 'This field'} must be positive';
    }

    return null;
  }

  /// Validate integer
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a whole number';
    }

    return null;
  }

  /// Validate positive integer
  static String? positiveInteger(String? value, {String? fieldName}) {
    final intError = integer(value, fieldName: fieldName);
    if (intError != null) return intError;

    final num = int.parse(value!);
    if (num < 0) {
      return '${fieldName ?? 'This field'} must be positive';
    }

    return null;
  }

  /// Validate minimum value
  static String? min(String? value, double minValue, {String? fieldName}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;

    final num = double.parse(value!);
    if (num < minValue) {
      return '${fieldName ?? 'Value'} must be at least $minValue';
    }

    return null;
  }

  /// Validate maximum value
  static String? max(String? value, double maxValue, {String? fieldName}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;

    final num = double.parse(value!);
    if (num > maxValue) {
      return '${fieldName ?? 'Value'} must be at most $maxValue';
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int minLen, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLen) {
      return '${fieldName ?? 'This field'} must be at least $minLen characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int maxLen, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (value.length > maxLen) {
      return '${fieldName ?? 'This field'} must be at most $maxLen characters';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
