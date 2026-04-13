import 'package:flutter/material.dart';
 
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.assetPath,
    required this.label,
    this.onTap,
  });
 
  final String assetPath;
  final String label;
  final VoidCallback? onTap;
 
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        assetPath,
        width: 40,
        height: 40,
        color: Colors.deepPurple,
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}