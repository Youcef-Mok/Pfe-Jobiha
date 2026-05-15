import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test DraggableScrollableController in Stack', (WidgetTester tester) async {
    final controller = DraggableScrollableController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              DraggableScrollableSheet(
                controller: controller,
                builder: (context, scrollController) {
                  return Container(color: Colors.blue);
                },
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final size = controller.isAttached ? controller.size : 0.0;
                  return Positioned(
                    top: 0,
                    left: 0,
                    bottom: size * 100,
                    child: Container(width: 100, color: Colors.red),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(Container), findsWidgets);
  });
}
