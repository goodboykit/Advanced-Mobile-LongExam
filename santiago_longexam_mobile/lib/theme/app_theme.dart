import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: UIConstants.iconM,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: UIConstants.elevationS,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: UIConstants.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
          ),
          side: BorderSide(color: AppColors.primary, width: 2),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingM,
            vertical: UIConstants.spacingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingM,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        elevation: UIConstants.elevationM,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: UIConstants.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: UIConstants.elevationM,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: UIConstants.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        ),
        titleTextStyle: AppTextStyles.heading4.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,
        titleLarge: AppTextStyles.heading3,
        titleMedium: AppTextStyles.heading4,
        titleSmall: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.bodyMedium,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        tertiary: AppColors.accentLight,
        surface: AppColors.grey800,
        background: AppColors.grey900,
        error: AppColors.errorLight,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.grey100,
        onBackground: AppColors.grey100,
        onError: AppColors.black,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.grey800,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: UIConstants.iconM,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: UIConstants.elevationS,
        shadowColor: AppColors.black.withOpacity(0.3),
        color: AppColors.grey800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        ),
      ),

      // Input Theme for Dark Mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingM,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey300,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey400,
        ),
      ),

      // Bottom Navigation Theme for Dark Mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.grey800,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.grey400,
        elevation: UIConstants.elevationM,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      // Floating Action Button Theme for Dark Mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.black,
        elevation: UIConstants.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        ),
      ),
    );
  }
}