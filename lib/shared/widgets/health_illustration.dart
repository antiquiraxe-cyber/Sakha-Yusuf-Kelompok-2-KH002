import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Ilustrasi kesehatan dengan fallback bawaan.
///
/// File preview berlisensi tidak ikut di-commit. Kalau aset tidak tersedia
/// (misalnya di clone bersih), widget menampilkan panel cyan + ikon, bukan
/// kotak error.
class HealthIllustration extends StatelessWidget {
  final String assetPath;
  final double height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double borderRadius;

  const HealthIllustration({
    super.key,
    required this.assetPath,
    this.height = 160,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.child_care_rounded,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: double.infinity,
          color: AppTheme.cyan,
          alignment: Alignment.center,
          child: Icon(fallbackIcon, size: 48, color: AppTheme.ink),
        ),
      ),
    );
  }
}
