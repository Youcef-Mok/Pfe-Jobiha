import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  child: Container(width: 100, height: 100, color: Colors.red),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
