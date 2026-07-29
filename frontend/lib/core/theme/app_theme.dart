import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de design tirés directement du Figma
abstract class AppColors {
  // Brand
  static const violet = Color(0xFF401E66);
  static const violetLight = Color(0x1A7F13EC);   // 10% opacity
  static const violetBorder = Color(0x0D7F13EC);  // 5% opacity

  // Neutrals
  static const background = Color(0xFFFCFBFB); // Global background for screens
  static const surfaceSecondary = Color(0xFFEFEDF2);
  static const surface = Color(0xFFFFFFFF);
  static const slate900 = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFF475569); // Darkened from 64748B
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);

  // Status
  static const activeBg = Color(0xFFDCFCE7);
  static const activeText = Color(0xFF15803D);
  static const draftBg = Color(0xFFF1F5F9);
  static const draftText = Color(0xFF475569);
  static const searchingBg = Color(0xFFEADCF8);
  static const searchingText = Color(0xFF401E66);

  // Input & Upload
  static const inputBorder = Color(0x338B5CF6);    // rgba(139,92,246,0.2)
  static const inputBg = Color(0xFFFFFFFF);
  static const uploadBg = Color(0x0D8B5CF6);        // rgba(139,92,246,0.05)
  static const uploadBorder = Color(0x338B5CF6);    // rgba(139,92,246,0.2)
  static const uploadIconBg = Color(0x1A8B5CF6);    // rgba(139,92,246,0.1)
  static const footerBorder = Color(0x1A8B5CF6);    // rgba(139,92,246,0.1)
}

abstract class AppTextStyles {
  // Pre-allocated GoogleFonts to avoid redundant computations in build methods
  static final poppins = GoogleFonts.poppins();
  static final manrope = GoogleFonts.manrope();
  static final inter = GoogleFonts.inter();
  static final plusJakarta = GoogleFonts.plusJakartaSans();


  static final heading1 = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.5,
    color: AppColors.slate900,
  );

  static final heading3 = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.56,
    color: AppColors.slate900,
  );

  static final bodyMedium = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate600,
  );

  static final labelBold = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static final labelMedium = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate600,
  );

  static final caption = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.33,
    color: AppColors.slate900,
  );

  static final captionLight = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.33,
    color: AppColors.slate600,
  );

  static final badge = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 10,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static final tabActive = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static final tabInactive = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate600,
  );

  static final heading2 = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.56,
    color: AppColors.slate900,
  );

  static final sectionTitle = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.5,
    color: AppColors.slate900,
  );

  static final fieldLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.43,
    color: const Color(0xFF334155),
  );

  static final inputText = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.19,
    color: const Color(0xFF6B7280),
  );

  static final inputValue = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: AppColors.slate900,
  );

  static final segmentActive = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static final segmentInactive = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: const Color(0xFF64748B),
  );

  static final publishBtn = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.5,
    color: Colors.white,
  );

  static final saveDraftBtn = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
    color: const Color(0xFF334155),
  );

  static final optionalBadge = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 10,
    height: 1.5,
    letterSpacing: 0.5,
    color: const Color(0xFF94A3B8),
  );

  // New specific styles for Candidate Home to avoid GoogleFonts calls in build
  static final h1Inter = GoogleFonts.inter(
    fontWeight: FontWeight.w800,
    fontSize: 25,
    height: 38 / 25,
    color: const Color(0xFF1D1B1F),
  );

  static final h2Inter = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 32 / 22,
    color: const Color(0xFF1D1B1F),
  );

  static final bodyInter = GoogleFonts.inter(
    fontSize: 17,
    height: 28 / 17,
    color: const Color(0xCCFFFFFF),
  );

  static final poppinsSemiBold14 = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.violet,
  );

  static final poppins16 = GoogleFonts.poppins(
    fontSize: 16,
    color: const Color(0xFF8D8DA6),
  );

  /// Centralized Performance-optimized Theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.violet,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(), // Use base inter theme for whole app
        fontFamily: 'Inter',
      );
}
