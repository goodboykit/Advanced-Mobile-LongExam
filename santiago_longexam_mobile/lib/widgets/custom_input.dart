import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;

  const CustomInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
        ],
        
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: AppTextStyles.bodyLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingM,
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const PasswordInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: widget.label ?? 'Password',
      hint: widget.hint ?? 'Enter your password',
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _isObscured,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: Icon(
        Icons.lock_outline,
        color: AppColors.primary,
        size: UIConstants.iconS,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: UIConstants.iconS,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const EmailInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email address',
      controller: controller,
      validator: validator ?? _defaultValidator,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      prefixIcon: Icon(
        Icons.email_outlined,
        color: AppColors.primary,
        size: UIConstants.iconS,
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? AppColors.grey700.withOpacity(0.5)
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint ?? 'Search...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingM,
            vertical: UIConstants.spacingS,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: AppColors.textSecondary,
            size: UIConstants.iconS,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: UIConstants.iconS,
                  ),
                  onPressed: onClear ?? () {
                    controller?.clear();
                    onChanged?.call('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class NumberInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool allowDecimals;
  final int? min;
  final int? max;

  const NumberInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.allowDecimals = false,
    this.min,
    this.max,
  });

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${label ?? 'Number'} is required';
    }
    
    final number = allowDecimals 
        ? double.tryParse(value) 
        : int.tryParse(value);
        
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min!) {
      return 'Must be at least $min';
    }
    
    if (max != null && number > max!) {
      return 'Must be at most $max';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator ?? _defaultValidator,
      onChanged: onChanged,
      keyboardType: allowDecimals 
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (!allowDecimals) FilteringTextInputFormatter.digitsOnly,
        if (allowDecimals) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
    );
  }
}

class PhoneInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const PhoneInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  String? _defaultValidator(String? value) {
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

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: label ?? 'Phone Number',
      hint: hint ?? 'Enter your phone number',
      controller: controller,
      validator: validator ?? _defaultValidator,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
        LengthLimitingTextInputFormatter(17), // +XX (XXX) XXX-XXXX
      ],
      prefixIcon: const Icon(
        Icons.phone_outlined,
        color: AppColors.primary,
        size: UIConstants.iconS,
      ),
    );
  }
}

class URLInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isRequired;

  const URLInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.isRequired = false,
  });

  String _normalizeUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return url;

    // If URL doesn't start with http:// or https://, add https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    return url;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'URL is required' : null;
    }

    final normalizedUrl = _normalizeUrl(value);

    try {
      final uri = Uri.parse(normalizedUrl);

      // Check if it has a valid scheme and host
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'URL must start with http:// or https://';
      }

      if (!uri.hasAuthority || uri.host.isEmpty) {
        return 'Please enter a valid URL with a domain';
      }

      // Check if host contains a dot (basic domain validation)
      if (!uri.host.contains('.')) {
        return 'Please enter a valid domain name';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: label ?? 'URL',
      hint: hint ?? 'Enter URL (protocol will be added automatically)',
      controller: controller,
      validator: validator ?? _defaultValidator,
      onChanged: (value) {
        onChanged?.call(value);
      },
      onSubmitted: (value) {
        if (controller != null && value.isNotEmpty) {
          final normalizedUrl = _normalizeUrl(value);
          controller!.text = normalizedUrl;
          controller!.selection = TextSelection.fromPosition(
            TextPosition(offset: normalizedUrl.length),
          );
        }
      },
      keyboardType: TextInputType.url,
      prefixIcon: const Icon(
        Icons.link_outlined,
        color: AppColors.primary,
        size: UIConstants.iconS,
      ),
    );
  }
}

class DropdownInput<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;

  const DropdownInput({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = true,
  });

  String? _defaultValidator(T? value) {
    if (isRequired && value == null) {
      return '${label ?? 'Selection'} is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[ 
          Text(
            label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
        ],
        
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator ?? _defaultValidator,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingM,
            ),
          ),
          style: AppTextStyles.bodyLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class EnhancedPasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool showStrengthIndicator;

  const EnhancedPasswordInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = true,
  });

  @override
  State<EnhancedPasswordInput> createState() => _EnhancedPasswordInputState();
}

class _EnhancedPasswordInputState extends State<EnhancedPasswordInput> {
  bool _isObscured = true;
  PasswordStrength _strength = PasswordStrength.weak;

  String? _defaultValidator(String? value) {
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

  PasswordStrength _calculateStrength(String password) {
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

  Color _getStrengthColor() {
    switch (_strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getStrengthText() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInput(
          label: widget.label ?? 'Password',
          hint: widget.hint ?? 'Enter your password',
          controller: widget.controller,
          validator: widget.validator ?? _defaultValidator,
          onChanged: (value) {
            if (widget.showStrengthIndicator) {
              setState(() {
                _strength = _calculateStrength(value);
              });
            }
            widget.onChanged?.call(value);
          },
          obscureText: _isObscured,
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: UIConstants.iconS,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: UIConstants.iconS,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ),
        
        if (widget.showStrengthIndicator && widget.controller?.text.isNotEmpty == true) ...[
          const SizedBox(height: UIConstants.spacingS),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_strength.index + 1) / 3,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                ),
              ),
              const SizedBox(width: UIConstants.spacingS),
              Text(
                _getStrengthText(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

enum PasswordStrength { weak, medium, strong }