import 'package:flutter/material.dart';

class InvitationAcceptSheet extends StatelessWidget {
  final String contactName;
  final String contactRole;
  final String? contactAvatar;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationAcceptSheet({
    super.key,
    required this.contactName,
    required this.contactRole,
    required this.onAccept,
    required this.onDecline,
    this.contactAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D3A1B5E),
            blurRadius: 0,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identity header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEFEDF2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3A1B5E).withValues(alpha: 0.10),
                            blurRadius: 0,
                            spreadRadius: 2,
                          ),
                        ],
                        image: contactAvatar != null
                            ? DecorationImage(
                                image: AssetImage(contactAvatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: contactAvatar == null
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 26)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF1D1B1F),
                          ),
                        ),
                        if (contactRole.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBD9FC).withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              contactRole,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF401E66),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Message box
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.fromLTRB(16, 15, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDF2),
                    border: Border.all(
                        color: const Color(0xFFEFEDF4), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 23 / 14,
                        color: Color(0xFF4A454F),
                      ),
                      children: [
                        const TextSpan(
                            text: 'Accepter la demande de message de '),
                        TextSpan(
                          text: contactName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF401E66)),
                        ),
                        const TextSpan(text: ' ?'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Refuser
                    Expanded(
                      child: GestureDetector(
                        onTap: onDecline,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEDF2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close,
                                  size: 14, color: Color(0xFF4A454F)),
                              SizedBox(width: 6),
                              Text(
                                'refuser',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF4A454F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Accepter
                    Expanded(
                      child: GestureDetector(
                        onTap: onAccept,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A1B5E),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x333A1B5E),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Color(0x333A1B5E),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Accepter',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer pill
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E0E7).withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
