import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d'utilisation"),
      ),
      body: const Center(
        child: Text('Terms and conditions will appear here.'),
      ),
    );
  }
}