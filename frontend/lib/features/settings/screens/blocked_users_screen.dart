import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptes bloqués'),
      ),
      body: const Center(
        child: Text('Blocked users will appear here.'),
      ),
    );
  }
}