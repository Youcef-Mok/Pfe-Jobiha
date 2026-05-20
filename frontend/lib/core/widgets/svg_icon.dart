import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget pour afficher des icônes SVG
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;

  const SvgIcon({
    super.key,
    required this.assetPath,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Chemins des icônes SVG
class SvgIcons {
  static const String briefcase = 'assets/icons/briefcase.svg';
  static const String briefcaseCheck = 'assets/icons/briefcase_check.svg';
  static const String calendar = 'assets/icons/calendar.svg';
  static const String fileText = 'assets/icons/file_text.svg';
}
