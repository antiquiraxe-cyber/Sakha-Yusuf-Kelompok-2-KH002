import 'package:flutter/material.dart';

/// Widget reusable untuk menampilkan kondisi error atau offline di seluruh aplikasi.
///
/// Mengikuti panduan UX:
/// - Visual yang ramah dan tidak menakutkan pengguna (soft tone)
/// - Penjelasan error yang manusiawi
/// - Selalu ada aksi pemulihan ("Coba Lagi" / Retry)
class ErrorStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Gagal Memuat Data',
    this.message =
        'Terjadi kendala saat memuat data. Pastikan perangkat Anda terhubung ke internet dan coba beberapa saat lagi.',
    this.actionLabel = 'Coba Lagi',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container dengan aksen merah lembut
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // Judul Error
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Penjelasan / Pesan Error
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Tombol "Coba Lagi" (Thumb-friendly target, min height 52dp)
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
