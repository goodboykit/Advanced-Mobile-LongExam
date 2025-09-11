import 'package:flutter/services.dart';

class InputFormatters {
  // Phone number formatter - allows digits, spaces, parentheses, hyphens, plus
  static List<TextInputFormatter> phoneNumber = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
    LengthLimitingTextInputFormatter(17), // +XX (XXX) XXX-XXXX
  ];

  // Numbers only formatter
  static List<TextInputFormatter> numbersOnly = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  // Decimal numbers formatter
  static List<TextInputFormatter> decimal = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];

  // Letters only formatter
  static List<TextInputFormatter> lettersOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ];

  // Letters and numbers formatter
  static List<TextInputFormatter> alphanumeric = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ];

  // Username formatter - letters, numbers, underscores
  static List<TextInputFormatter> username = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
    LengthLimitingTextInputFormatter(20),
  ];

  // Email formatter - basic email characters
  static List<TextInputFormatter> email = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
  ];

  // URL formatter - URL valid characters
  static List<TextInputFormatter> url = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9:/.?&=_-]')),
  ];

  // Age formatter - 2-3 digits
  static List<TextInputFormatter> age = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(3),
  ];

  // Quantity formatter - up to 6 digits for inventory
  static List<TextInputFormatter> quantity = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  // Name formatter - letters and spaces only
  static List<TextInputFormatter> name = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
    LengthLimitingTextInputFormatter(50),
  ];

  // Custom formatter for specific character limits
  static List<TextInputFormatter> maxLength(int length) => [
    LengthLimitingTextInputFormatter(length),
  ];

  // Custom formatter for specific regex pattern
  static List<TextInputFormatter> pattern(String regexPattern) => [
    FilteringTextInputFormatter.allow(RegExp(regexPattern)),
  ];

  // Combine multiple formatters
  static List<TextInputFormatter> combine(List<List<TextInputFormatter>> formatters) {
    final combined = <TextInputFormatter>[];
    for (final formatterList in formatters) {
      combined.addAll(formatterList);
    }
    return combined;
  }
}

// Custom formatters for specific use cases
class CustomInputFormatters {
  // Credit card formatter (adds spaces every 4 digits)
  static TextInputFormatter creditCard = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      final text = newValue.text.replaceAll(' ', '');
      if (text.length <= 4) {
        return newValue;
      }
      
      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        buffer.write(text[i]);
        if ((i + 1) % 4 == 0 && i + 1 != text.length) {
          buffer.write(' ');
        }
      }
      
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    },
  );

  // Phone number formatter with automatic formatting
  static TextInputFormatter phoneNumberAutoFormat = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (text.length <= 3) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      } else if (text.length <= 6) {
        final formatted = '(${text.substring(0, 3)}) ${text.substring(3)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else if (text.length <= 10) {
        final formatted = '(${text.substring(0, 3)}) ${text.substring(3, 6)}-${text.substring(6)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else {
        final formatted = '(${text.substring(0, 3)}) ${text.substring(3, 6)}-${text.substring(6, 10)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    },
  );

  // Uppercase formatter
  static TextInputFormatter uppercase = TextInputFormatter.withFunction(
    (oldValue, newValue) => TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    ),
  );

  // Lowercase formatter
  static TextInputFormatter lowercase = TextInputFormatter.withFunction(
    (oldValue, newValue) => TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    ),
  );

  // Capitalize first letter formatter
  static TextInputFormatter capitalizeFirst = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      final text = newValue.text;
      final capitalized = text[0].toUpperCase() + text.substring(1).toLowerCase();
      
      return TextEditingValue(
        text: capitalized,
        selection: newValue.selection,
      );
    },
  );

  // Proper case formatter (capitalize each word)
  static TextInputFormatter properCase = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      final words = newValue.text.split(' ');
      final properCased = words.map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
      
      return TextEditingValue(
        text: properCased,
        selection: newValue.selection,
      );
    },
  );
}