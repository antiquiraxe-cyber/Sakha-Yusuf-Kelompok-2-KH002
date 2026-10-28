import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/shared/widgets/empty_state_widget.dart';
import 'package:langkahawal/shared/widgets/error_state_widget.dart';
import 'package:langkahawal/shared/widgets/skeleton_loader.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('menampilkan title, deskripsi, dan tombol CTA dengan benar',
        (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum Ada Data Anak',
              description: 'Tambahkan data anak Anda untuk mulai memantau.',
              actionLabel: 'Tambah Anak',
              onAction: () {
                actionTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Data Anak'), findsOneWidget);
      expect(
          find.text('Tambahkan data anak Anda untuk mulai memantau.'), findsOneWidget);
      expect(find.text('Tambah Anak'), findsOneWidget);
      expect(find.byIcon(Icons.child_care), findsOneWidget);

      await tester.tap(find.text('Tambah Anak'));
      await tester.pump();

      expect(actionTapped, isTrue);
    });
  });

  group('ErrorStateWidget Tests', () {
    testWidgets('menampilkan judul, pesan error, dan memanggil onRetry saat diklik',
        (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              title: 'Gagal Memuat Data',
              message: 'Koneksi terputus. Silakan coba lagi.',
              actionLabel: 'Coba Lagi',
              onRetry: () {
                retryTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Gagal Memuat Data'), findsOneWidget);
      expect(find.text('Koneksi terputus. Silakan coba lagi.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });
  });

  group('SkeletonLoader Tests', () {
    testWidgets('DashboardSkeletonLoader dapat dirender dengan mulus tanpa error',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(DashboardSkeletonLoader), findsOneWidget);
      expect(find.byType(SkeletonShimmer), findsOneWidget);
      expect(find.byType(SkeletonCard), findsWidgets);
      expect(find.byType(SkeletonLine), findsWidgets);
      expect(find.byType(SkeletonCircle), findsWidgets);

      // Pastikan animasi pulsing berjalan
      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
