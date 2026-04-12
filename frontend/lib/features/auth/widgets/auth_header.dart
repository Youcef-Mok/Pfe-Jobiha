import 'package:flutter/material.dart';
import 'auth_logo.dart';

class AuthHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AuthHeader({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF4F4F5),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBackPressed != null)
            Positioned(
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Color(0xFF3A1B5E),
                ),
                onPressed: onBackPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          const AuthLogo(iconSize: 40, fontSize: 40),
        ],
      ),
    );
  }
}