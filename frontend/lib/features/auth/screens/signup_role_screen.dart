import 'package:flutter/material.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_header.dart';

class SignupRoleScreen extends StatefulWidget {
  const SignupRoleScreen({super.key});

  @override
  State<SignupRoleScreen> createState() => _SignupRoleScreenState();
}

class _SignupRoleScreenState extends State<SignupRoleScreen> {
  // Tracks which card is selected: 'recruteur' or 'employe' or null
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    _RoleCard(
                      title: 'Recruteur',
                      subtitle: 'Recrute des employés\nresponsables et compétents',
                      icon: Icons.work_outline,
                      isSelected: _selectedRole == 'recruteur',
                      onTap: () => setState(() => _selectedRole = 'recruteur'),
                    ),

                    const SizedBox(height: 20),

                    _RoleCard(
                      title: 'Employé',
                      subtitle: 'Trouve un job qui te convient\nrapidement et facilement',
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == 'employe',
                      onTap: () => setState(() => _selectedRole = 'employe'),
                    ),

                    const Spacer(flex: 2),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedRole == null
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/signup-form',
                                    arguments: _selectedRole);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A1B5E),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continuer →',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable role card widget ─────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A1B5E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3A1B5E)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3A1B5E).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            // Icon in a circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF6B35D9).withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.white : const Color(0xFF6B35D9),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white70 : Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}