import 'package:flutter/material.dart';
import '../widgets/auth_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF4F4F5), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: AuthLogo(iconSize: 40, fontSize: 40),
              ),
            ),

            // ── Spacer: ~21% of screen height ─────────────────────────────
            SizedBox(height: screenHeight * 0.21),

            // ── Text block ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "plus d'oppurtunites\nque jamais",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3A1B5E),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    "Trouvez un job qui vous convient\nrapidement,facilement de chez vous",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7C7580),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.56,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // ── S'inscrire button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A1B5E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "S'inscrire →",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Se connecter button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3A1B5E),
                        side: const BorderSide(
                            color: Color(0xFF3A1B5E), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}