// ============ Regex Validators for the App ============
// Reusable validation functions. Each returns an error message
// or null if the input is valid.

/// Email: must have something@something.something
String? validateEmail(String value) {
  if (value.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

/// Phone: Bangladeshi number — 11 digits starting with 01
String? validatePhone(String value) {
  if (value.trim().isEmpty) return 'Phone number is required';
  final regex = RegExp(r'^01[3-9]\d{8}$');
  if (!regex.hasMatch(value.trim()))
    return 'Enter a valid 11-digit phone number (01XXXXXXXXX)';
  return null;
}

/// Student ID: starts with 018, only digits, at least 7 characters
String? validateStudentId(String value) {
  if (value.trim().isEmpty) return 'Student ID is required';
  final regex = RegExp(r'^018\d{4,}$');
  if (!regex.hasMatch(value.trim()))
    return 'Student ID must start with 018 and be at least 7 digits';
  return null;
}

/// Name: only letters and spaces, at least 3 characters
String? validateName(String value) {
  if (value.trim().isEmpty) return 'Name is required';
  final regex = RegExp(r'^[a-zA-Z\s.]{3,}$');
  if (!regex.hasMatch(value.trim()))
    return 'Name must be at least 3 letters (no numbers)';
  return null;
}

/// Password: minimum 6 characters, anything allowed
String? validatePassword(String value) {
  if (value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

/// Batch: 1-3 digit number (e.g., 56, 7, 120)
String? validateBatch(String value) {
  if (value.trim().isEmpty) return 'Batch is required';
  final regex = RegExp(r'^\d{1,3}$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid batch number';
  return null;
}

/// Amount: positive number (integer or decimal)
String? validateAmount(String value) {
  if (value.trim().isEmpty) return 'Amount is required';
  final regex = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!regex.hasMatch(value.trim()))
    return 'Enter a valid amount (e.g., 500 or 99.50)';
  return null;
}

/// TrxID: alphanumeric, at least 5 characters
String? validateTrxId(String value) {
  if (value.trim().isEmpty) return 'Transaction ID is required';
  final regex = RegExp(r'^[A-Za-z0-9]{5,}$');
  if (!regex.hasMatch(value.trim()))
    return 'TrxID must be at least 5 alphanumeric characters';
  return null;
}

/// Address: at least 5 characters
String? validateAddress(String value) {
  if (value.trim().isEmpty) return 'Address is required';
  if (value.trim().length < 5) return 'Address must be at least 5 characters';
  return null;
}

/// Department: only letters, 2-10 characters (e.g., CSE, EEE, BBA)
String? validateDepartment(String value) {
  if (value.trim().isEmpty) return 'Department is required';
  final regex = RegExp(r'^[a-zA-Z]{2,10}$');
  if (!regex.hasMatch(value.trim()))
    return 'Enter a valid department (e.g., CSE)';
  return null;
}

/// Non-empty (for dropdowns like gender, blood group, payment method)
String? validateRequired(String value, String fieldName) {
  if (value.trim().isEmpty) return '$fieldName is required';
  return null;
}
