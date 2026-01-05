import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color primaryColor = Color(0xFFE1306C); 
  static const Color secondaryColor = Color(0xFFFD1D1D); 
  static const Color accentColor = Color(0xFF833AB4); 
  
  
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  
  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF737373);
  static const Color textHint = Color(0xFFB2BEC3);
  
  
  static const Color successColor = Color(0xFF00B894);
  static const Color errorColor = Color(0xFFED4956);
  static const Color warningColor = Color(0xFFFDCB6E);
  static const Color infoColor = Color(0xFF74B9FF);
  
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFD1D1D), 
      Color(0xFFE1306C), 
      Color(0xFFC13584), 
      Color(0xFF833AB4), 
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFDC80), 
      Color(0xFFFCAF45), 
      Color(0xFFF77737), 
      Color(0xFFF56040), 
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF405DE6), 
      Color(0xFF5B51D8), 
      Color(0xFF833AB4), 
      Color(0xFFC13584), 
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFFFFFFF)],
  );

  
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    labelStyle: const TextStyle(color: textSecondary),
    hintStyle: const TextStyle(color: textHint),
  );

  
  static CardThemeData cardTheme = CardThemeData(
    color: cardColor,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: textPrimary),
    titleTextStyle: TextStyle(
      color: textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );

  
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textHint,
    height: 1.3,
  );

  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: cardTheme,
    appBarTheme: appBarTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    textTheme: const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelSmall: caption,
    ),
    fontFamily: 'Avenir',
  );

  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

