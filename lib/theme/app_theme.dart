import 'package:flutter/material.dart';

/// App Theme Configuration
/// Matches the React UI color scheme and styling
class AppTheme {
  // Primary brand colors from React UI
  static const Color primaryOrange = Color(0xFFFE5C01);
  static const Color primaryOrangeHover = Color(0xFFE55301);
  static const Color background = Color(0xFFF8FAFC);

  // Gray scale colors
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // State colors
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color green50 = Color(0xFFECFDF5);
  static const Color green200 = Color(0xFFA7F3D0);
  static const Color green700 = Color(0xFF047857);
  static const Color green900 = Color(0xFF064E3B);
  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple200 = Color(0xFFDDD6FE);

  // Additional colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange200 = Color(0xFFFED7AA);

  // Text styles matching React UI
  static const String fontFamilyPrimary = 'Arial'; // Fallback to system Arial
  static const String fontFamilyHeading = 'Trebuchet MS';

  static TextTheme get textTheme => const TextTheme(
    headlineMedium: TextStyle(
      fontFamily: fontFamilyHeading,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: gray900,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: gray700,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: gray600,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: gray700,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: gray700,
    ),
  );

  // Spacing constants
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border radius
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXL = 16.0;

  // Layout constraints
  static const double maxContentWidth = 672.0;
  static const double pageGutter = 8.0;
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  // Input field styling
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: gray50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: gray300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: gray300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: primaryOrange, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: gray700,
    ),
    hintStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: gray400,
    ),
  );

  // Main app theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: white,
    colorScheme: ColorScheme.light(
      primary: primaryOrange,
      secondary: gray100,
      surface: white,
      error: Colors.red,
    ),
    textTheme: textTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryOrange,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    ),
  );
}
