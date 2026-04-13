
import 'package:flutter/material.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibilité'),
      ),
      body: const Center(
        child: Text('Accessibility options will appear here.'),
      ),
    );
  }
}