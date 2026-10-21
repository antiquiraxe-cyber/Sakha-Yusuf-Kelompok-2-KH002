import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/tracking/domain/services/growth_evaluation_service.dart';
import 'package:langkahawal/features/tracking/presentation/widgets/growth_evaluation_sheet.dart';

void main() {
  testWidgets('showGrowthEvaluationSheet menampilkan evaluasi dan panduan nutrisi dengan benar',
      (tester) async {
    final eval = GrowthEvaluationService.evaluate(
      ageInMonths: 12,
      gender: Gender.male,
      weightKg: 5.0,
      heightCm: 50.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showGrowthEvaluationSheet(
                    context,
                    childName: 'Yusuf',
                    eval: eval,
                    subtitle: 'Data telah berhasil disimpan',
                  );
                },
                child: const Text('Buka Evaluasi'),
              );
            },
          ),
        ),
      ),
    );

    // Buka modal sheet
    await tester.tap(find.text('Buka Evaluasi'));
    await tester.pumpAndSettle();

    // Verifikasi teks evaluasi muncul di layar
    expect(find.text('Hasil Pemantauan Yusuf'), findsOneWidget);
    expect(find.text('Data telah berhasil disimpan'), findsOneWidget);
    expect(find.text(eval.title), findsOneWidget);
    expect(find.text('Saran Nutrisi & Makanan:'), findsOneWidget);
    // Scroll sampai tombol terlihat
    await tester.scrollUntilVisible(
      find.text('Mengerti & Selesai'),
      100.0,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Mengerti & Selesai'), findsOneWidget);

    // Verifikasi tombol dismiss dapat menutup sheet
    await tester.tap(find.text('Mengerti & Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Pemantauan Yusuf'), findsNothing);
  });
}
