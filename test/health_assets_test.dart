import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/shared/widgets/health_illustration.dart';

void main() {
  testWidgets('ilustrasi memakai fallback saat aset tidak tersedia',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HealthIllustration(
            assetPath: 'assets/illustrations/tidak-ada.jpg',
            fallbackIcon: Icons.child_care_rounded,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.child_care_rounded), findsOneWidget);
  });
}
