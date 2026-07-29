import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CandidateProfileBio extends StatelessWidget {
  final String text;

  const CandidateProfileBio({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}

