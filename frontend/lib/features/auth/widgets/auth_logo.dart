import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? textColor;

  const AuthLogo({
    super.key,
    this.iconSize = 40,
    this.fontSize = 40,
    this.textColor = const Color(0xFF3A1B5E),
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo_full.png',
      height: iconSize,
      fit: BoxFit.contain,
    );
  }
}