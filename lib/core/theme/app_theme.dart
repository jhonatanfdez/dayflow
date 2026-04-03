import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFFFF6584);
  static const Color background = Color(0xFFF8F9FA);
  static const Color inactiveGrey = Color(0xFFB0BEC5);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          background: background,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.08),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: inactiveGrey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      );
}
