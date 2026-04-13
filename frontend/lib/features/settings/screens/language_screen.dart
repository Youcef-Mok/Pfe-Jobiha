import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langues et traductions'),
      ),
      body: const Center(
        child: Text('Language and translation options will appear here.'),
      ),
    );
  }
}