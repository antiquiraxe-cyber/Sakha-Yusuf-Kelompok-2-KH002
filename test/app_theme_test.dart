import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/core/theme/app_theme.dart';

void main() {
  group('AppTheme kesehatan', () {
    final theme = AppTheme.lightTheme;

    test('komponen wajib dan palet referensi terpasang', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.canvas);
      expect(theme.colorScheme.primary, AppTheme.ink);
      expect(theme.colorScheme.primaryContainer, AppTheme.cyan);
      expect(theme.colorScheme.secondary, AppTheme.coral);
      expect(theme.colorScheme.tertiary, AppTheme.sage);
      expect(theme.navigationBarTheme.backgroundColor, AppTheme.ink);
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.chipTheme.labelStyle, isNotNull);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.inputDecorationTheme.focusedBorder, isNotNull);
    });

    test('semua gaya teks yang dipakai layar sudah terdefinisi', () {
      final t = theme.textTheme;
      for (final style in [
        t.headlineLarge,
        t.headlineMedium,
        t.headlineSmall,
        t.titleLarge,
        t.titleMedium,
        t.titleSmall,
        t.bodyLarge,
        t.bodyMedium,
        t.bodySmall,
        t.labelLarge,
        t.labelMedium,
        t.labelSmall,
      ]) {
        expect(style, isNotNull);
        expect(style!.fontSize, isNotNull);
      }
    });

    test('teks dan tombol lulus kontras WCAG AA', () {
      final scheme = theme.colorScheme;
      expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(4.5));
      expect(_contrast(scheme.onSurfaceVariant, scheme.surface),
          greaterThan(4.5));
      expect(_contrast(scheme.onPrimary, scheme.primary), greaterThan(4.5));
      expect(_contrast(AppTheme.ink, AppTheme.cyan), greaterThan(4.5));
      expect(_contrast(AppTheme.ink, AppTheme.sageSoft), greaterThan(4.5));
      expect(_contrast(AppTheme.ink, AppTheme.coralSoft), greaterThan(4.5));
    });
  });
}

/// Rasio kontras WCAG antara dua warna solid.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
