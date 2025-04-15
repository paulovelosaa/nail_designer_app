import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final Color _warmGray = const Color(0xFFF2F2F2); // tom tipo ouro branco
  static final Color _accentPink = const Color(0xFFE91E63);
  static final Color _textColor = Colors.black;

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: _warmGray,
      primaryColor: _accentPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentPink,
        brightness: Brightness.light,
        background: _warmGray,
        primary: _accentPink,
        onPrimary: Colors.white,
        onBackground: _textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _warmGray,
        foregroundColor: _textColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        bodyMedium: TextStyle(color: _textColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentPink),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentPink, width: 2),
        ),
        labelStyle: TextStyle(color: _textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
