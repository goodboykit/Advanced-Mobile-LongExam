import 'package:flutter/material.dart';
import '../constants.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: UIConstants.iconS),
            const SizedBox(width: UIConstants.spacingS),
          ],
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: _getTextColor(theme),
            ),
          ),
        ],
      ],
    );

    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = Container(
          width: width,
          height: height ?? UIConstants.buttonHeightM,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            boxShadow: const [AppShadows.soft],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
              ),
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingL,
                vertical: UIConstants.spacingM,
              ),
            ),
            child: buttonChild,
          ),
        );
        break;
        
      case ButtonType.secondary:
        button = Container(
          width: width,
          height: height ?? UIConstants.buttonHeightM,
          decoration: BoxDecoration(
            gradient: AppGradients.secondaryGradient,
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            boxShadow: const [AppShadows.soft],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
              ),
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingL,
                vertical: UIConstants.spacingM,
              ),
            ),
            child: buttonChild,
          ),
        );
        break;
        
      case ButtonType.outline:
        button = SizedBox(
          width: width,
          height: height ?? UIConstants.buttonHeightM,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
              ),
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingL,
                vertical: UIConstants.spacingM,
              ),
            ),
            child: buttonChild,
          ),
        );
        break;
        
      case ButtonType.text:
        button = SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
                vertical: UIConstants.spacingS,
              ),
            ),
            child: buttonChild,
          ),
        );
        break;
    }

    return button;
  }

  Color _getTextColor(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return theme.colorScheme.primary;
    }
  }
}

// Specialized button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
      icon: icon,
      width: width,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      isLoading: isLoading,
      icon: icon,
      width: width,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const OutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      isLoading: isLoading,
      icon: icon,
      width: width,
    );
  }
}