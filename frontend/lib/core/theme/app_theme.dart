import 'package:flutter/material.dart';

/// Tokens de design tirés directement du Figma
abstract class AppColors {
  // Brand
  static const violet = Color(0xFF401E66);
  static const violetLight = Color(0x1A7F13EC);   // 10% opacity
  static const violetBorder = Color(0x0D7F13EC);  // 5% opacity

  // Neutrals
  static const background = Color(0xFFF7F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const slate900 = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFF64748B);

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
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
}

abstract class AppTextStyles {
  static const _family = 'PlusJakartaSans';

  static const heading1 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.5,
    color: AppColors.slate900,
  );

  static const heading3 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.56,
    color: AppColors.slate900,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate300,
  );

  static const labelBold = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static const labelMedium = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate600,
  );

  static const caption = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.33,
    color: AppColors.slate900,
  );

  static const captionLight = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.33,
    color: AppColors.slate300,
  );

  static const badge = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const tabActive = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static const tabInactive = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.43,
    color: AppColors.slate300,
  );

  static const heading2 = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.56,
    color: AppColors.slate900,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.5,
    color: AppColors.slate900,
  );

  static const fieldLabel = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.43,
    color: Color(0xFF334155),
  );

  static const inputText = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.19,
    color: Color(0xFF6B7280),
  );

  static const inputValue = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: AppColors.slate900,
  );

  static const segmentActive = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: AppColors.violet,
  );

  static const segmentInactive = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.43,
    color: Color(0xFF64748B),
  );

  static const publishBtn = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.5,
    color: Colors.white,
  );

  static const saveDraftBtn = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
    color: Color(0xFF334155),
  );

  static const optionalBadge = TextStyle(
    fontFamily: _family,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    height: 1.5,
    letterSpacing: 0.5,
    color: Color(0xFF94A3B8),
  );
}
