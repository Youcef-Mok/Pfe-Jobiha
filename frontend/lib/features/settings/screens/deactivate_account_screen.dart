import 'package:flutter/material.dart';

class DeactivateAccountScreen extends StatelessWidget {
  const DeactivateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Account'),
      ),
      body: const Center(
        child: Text('Account deactivation options will appear here.'),
      ),
    );
  }
}