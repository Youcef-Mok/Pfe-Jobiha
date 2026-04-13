import 'package:flutter/material.dart';

class ApplicationsReceivedScreen extends StatelessWidget {
  const ApplicationsReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Received'),
      ),
      body: const Center(
        child: Text('Received applications will appear here.'),
      ),
    );
  }
}