import 'package:flutter/material.dart';

class ApplicationsSentScreen extends StatelessWidget {
  const ApplicationsSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Sent'),
      ),
      body: const Center(
        child: Text('Sent applications will appear here.'),
      ),
    );
  }
}