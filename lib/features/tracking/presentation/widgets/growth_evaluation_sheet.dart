import 'package:flutter/material.dart';
import '../../domain/services/growth_evaluation_service.dart';

/// Menampilkan Bottom Sheet edukatif hasil pemantauan pertumbuhan dan panduan nutrisi.
/// Dapat dipanggil dari TrackingScreen (saat simpan baru / klik riwayat)
/// maupun dari ChildListScreen (saat klik kartu evaluasi di Dashboard).
Future<void> showGrowthEvaluationSheet(
  BuildContext context, {
  required String childName,
  required GrowthEvaluationResult eval,
  String? subtitle,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final Color headerColor;
  final Color containerBg;
  final IconData statusIcon;

  switch (eval.alertLevel) {
    case GrowthAlertLevel.danger:
      headerColor = Colors.red.shade700;
      containerBg = Colors.red.shade50;
      statusIcon = Icons.error_outline_rounded;
      break;
    case GrowthAlertLevel.warning:
      headerColor = Colors.orange.shade800;
      containerBg = Colors.orange.shade50;
      statusIcon = Icons.warning_amber_rounded;
      break;
    case GrowthAlertLevel.normal:
      headerColor = Colors.green.shade700;
      containerBg = Colors.green.shade50;
      statusIcon = Icons.check_circle_outline_rounded;
      break;
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: containerBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: headerColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Pemantauan $childName',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle ?? 'Evaluasi Pertumbuhan & Saran Gizi',
                            style: TextStyle(
                              fontSize: 12,
                              color: headerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: containerBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: headerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        eval.summary,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.restaurant_rounded,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Saran Nutrisi & Makanan:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...eval.foodRecommendations.map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Expanded(
                          child: Text(
                            rec,
                            style:
                                const TextStyle(fontSize: 12.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (eval.foodsToAvoid.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.cancel_outlined,
                          size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Makanan yang Perlu Dibatasi:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...eval.foodsToAvoid.map(
                    (avoid) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✕ ',
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          Expanded(
                            child: Text(
                              avoid,
                              style:
                                  const TextStyle(fontSize: 12, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 15)),
                      Expanded(
                        child: Text(
                          eval.clinicalAction,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Mengerti & Selesai'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
