import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo / Icon ──────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // ── App name ─────────────────────────────────────────────
              const Text(
                'Jobiha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 40),

              // ── Headline ──────────────────────────────────────────────
              const Text(
                "plus d'opportunités\nque jamais",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9C6FFF),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtitle ──────────────────────────────────────────────
              const Text(
                "Trouvez un job qui vous convient\nrapidement, facilement de chez vous.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // ── S'inscrire button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B35D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "S'inscrire →",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Se connecter button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}