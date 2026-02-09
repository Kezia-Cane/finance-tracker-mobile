import 'package:flutter/material.dart';

/// AppTheme - Design System for Finance Tracker
/// 
/// Based on UI/UX Pro Max recommendations:
/// - Style: Glassmorphism + Dark Mode
/// - Typography: IBM Plex Sans (Google Fonts)
/// - Colors: Dark blue/indigo with teal/cyan accents
/// - Effects: Subtle borders, light reflections, layered Z-depth
/// 
/// This provides a premium fintech aesthetic with high contrast
/// and accessibility-compliant color combinations.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============ COLOR PALETTE ============
  
  /// Primary colors - Deep indigo/blue for trust and professionalism
  static const Color primaryDark = Color(0xFF0F172A);    // Slate 900
  static const Color primaryMedium = Color(0xFF1E293B);  // Slate 800
  static const Color primaryLight = Color(0xFF334155);   // Slate 700
  
  /// Accent colors - Teal/Cyan for CTAs and highlights
  static const Color accentPrimary = Color(0xFF06B6D4);  // Cyan 500
  static const Color accentSecondary = Color(0xFF0891B2); // Cyan 600
  static const Color accentTertiary = Color(0xFF22D3EE);  // Cyan 400
  
  /// Semantic colors
  static const Color success = Color(0xFF10B981);   // Emerald 500
  static const Color successLight = Color(0xFF34D399); // Emerald 400
  static const Color error = Color(0xFFEF4444);     // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color warning = Color(0xFFF59E0B);   // Amber 500
  static const Color info = Color(0xFF3B82F6);      // Blue 500
  
  /// Neutral colors
  static const Color textPrimary = Color(0xFFF8FAFC);    // Near white
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate 400
  static const Color textMuted = Color(0xFF64748B);      // Slate 500
  static const Color surfaceDark = Color(0xFF0F172A);    // Slate 900
  static const Color surfaceMedium = Color(0xFF1E293B);  // Slate 800
  static const Color surfaceLight = Color(0xFF334155);   // Slate 700
  static const Color divider = Color(0xFF475569);        // Slate 600
  
  /// Glass effect colors
  static const Color glassBg = Color(0x1AFFFFFF);        // White 10%
  static const Color glassBorder = Color(0x33FFFFFF);    // White 20%
  static const Color glassHighlight = Color(0x0DFFFFFF); // White 5%

  // ============ GRADIENTS ============
  
  /// Primary gradient for cards and backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );
  
  /// Accent gradient for CTAs and highlights
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF06B6D4),
      Color(0xFF0891B2),
    ],
  );
  
  /// Success gradient for income indicators
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );
  
  /// Error gradient for expense indicators
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );
  
  /// Premium glass gradient overlay
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  // ============ SPACING ============
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  // ============ BORDER RADIUS ============
  
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 9999.0;

  // ============ SHADOWS ============
  
  /// Subtle shadow for cards
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Medium shadow for elevated components
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Large shadow for modals and floating elements
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// Glow effect for accent elements
  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: accentPrimary.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  /// Success glow for income indicators
  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color: success.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ============ ANIMATION DURATIONS ============
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // ============ THEME DATA ============
  
  /// Get the complete dark theme for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        onPrimary: primaryDark,
        secondary: accentSecondary,
        onSecondary: textPrimary,
        tertiary: accentTertiary,
        surface: surfaceMedium,
        onSurface: textPrimary,
        error: error,
        onError: textPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: surfaceDark,
      
      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: surfaceMedium,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: textMuted,
        ),
      ),
      
      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: primaryDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceMedium,
        selectedItemColor: accentPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: spacingMd,
      ),
      
      // Text theme (IBM Plex Sans)
      fontFamily: 'IBMPlexSans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
