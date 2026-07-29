import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test Positioned inside AnimatedBuilder', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
      ),
    );
    expect(find.byType(Container), findsOneWidget);
  });
}
