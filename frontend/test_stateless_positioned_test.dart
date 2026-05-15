import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyPositioned extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(width: 50, height: 50, color: Colors.blue),
    );
  }
}

void main() {
  testWidgets('Test StatelessWidget returning Positioned in Stack', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              MyPositioned(),
            ],
          ),
        ),
      ),
    );
    final error = tester.takeException();
    if (error != null) {
      print('Caught expected error: $error');
    } else {
      print('No error caught!');
    }
  });
}
