class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  // Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }
    
    return null;
  }

  // URL validation
  static String? validateURL(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'URL is required' : null;
    }
    
    final urlPattern = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    
    if (!urlPattern.hasMatch(value.trim())) {
      return 'Please enter a valid URL (http:// or https://)';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {
    int? min,
    int? max,
    bool allowDecimals = false,
    String? fieldName,
  }) {
    final name = fieldName ?? 'Number';
    
    if (value == null || value.trim().isEmpty) {
      return '$name is required';
    }
    
    final number = allowDecimals 
        ? double.tryParse(value) 
        : int.tryParse(value);
        
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Must be at most $max';
    }
    
    return null;
  }

  // Age validation
  static String? validateAge(String? value, {int minAge = 18, int maxAge = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value.trim());
    if (age == null || age < minAge || age > maxAge) {
      return 'Age must be between $minAge and $maxAge';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Name validation (for first name, last name)
  static String? validateName(String? value, {String? fieldName}) {
    final name = fieldName ?? 'Name';
    
    if (value == null || value.trim().isEmpty) {
      return '$name is required';
    }
    
    if (value.trim().length < 2) {
      return '$name must be at least 2 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$name can only contain letters and spaces';
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.trim().length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  // Text length validation
  static String? validateTextLength(String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    final name = fieldName ?? 'Text';
    
    if (value == null || value.trim().isEmpty) {
      return '$name is required';
    }
    
    final length = value.trim().length;
    
    if (minLength != null && length < minLength) {
      return '$name must be at least $minLength characters';
    }
    
    if (maxLength != null && length > maxLength) {
      return '$name cannot exceed $maxLength characters';
    }
    
    return null;
  }

  // Multiple validation combiner
  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

// Password strength calculator
enum PasswordStrength { weak, medium, strong }

class PasswordStrengthCalculator {
  static PasswordStrength calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}