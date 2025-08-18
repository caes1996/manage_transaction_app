import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';

const Color backgroundColor = Color(0xFFF5F7FA);
const Color primaryColor = Color(0xFF004481);
const Color secondaryColor = Color(0xFF1C1F26);
const Color errorColor = Color(0xFFD32F2F);

final ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryColor,
  onPrimary: primaryColor.contrast,
  secondary: secondaryColor,
  onSecondary: secondaryColor.contrast,
  error: errorColor,
  onError: Colors.white,

  surface: backgroundColor,
  onSurface: backgroundColor.contrast,

  surfaceContainerHighest: Color(0xFFE8EDF2),
  onSurfaceVariant: Color(0xFF5B6776),
);

final TextTheme _textTheme = GoogleFonts.poppinsTextTheme(
  TextTheme(
    bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: colorScheme.onSurface),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: colorScheme.onSurface.withValues(alpha: 0.7)),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: colorScheme.onSurface.withValues(alpha: 0.7)),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface.withValues(alpha: 0.7)),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface.withValues(alpha: 0.7)),
  )
);

final ThemeData themeData = ThemeData(
  colorScheme: colorScheme,
  textTheme: _textTheme,
);