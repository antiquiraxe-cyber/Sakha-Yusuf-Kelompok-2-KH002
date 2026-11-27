import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../milestone/domain/entities/milestone_entity.dart';
import '../../../milestone/presentation/providers/milestone_provider.dart';

class KpspProgressChart extends ConsumerWidget {
  final String childId;
  final String childName;
  const KpspProgressChart({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = milestoneHistoryStreamProvider(childId);
    return ref
        .watch(provider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              ErrorStateWidget(onRetry: () => ref.invalidate(provider)),
          data: (history) {
            if (history.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada hasil KPSP untuk $childName. Simpan evaluasi di tab Milestone untuk melihat grafik.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            // The history stream supplies the newest sessions first.
            final sessions = history.take(5).toList().reversed.toList();
            final theme = Theme.of(context);
            final groups = <BarChartGroupData>[];
            final details = <Widget>[];
            for (final (i, session) in sessions.indexed) {
              final (label, color) = switch (session.status) {
                MilestoneStatus.sesuai => ('Sesuai', AppTheme.statusSesuai),
                MilestoneStatus.meragukan => (
                  'Meragukan',
                  AppTheme.statusMeragukan,
                ),
                MilestoneStatus.penyimpangan => (
                  'Penyimpangan',
                  AppTheme.statusPenyimpangan,
                ),
              };
              final count = session.answers.length;
              final percent = count == 0
                  ? null
                  : 100 * session.totalYes / count;
              groups.add(
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: percent ?? 0,
                      color: color,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
              final score = percent == null
                  ? 'Skor tidak tersedia'
                  : '${session.totalYes}/$count Ya · ${percent.round()}%';
              details.add(
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${DateFormat('dd/MM/yyyy, HH:mm').format(session.evaluatedAt)} · ${session.ageMonthEvaluated} bulan',
                  ),
                  subtitle: Text('$score · $label'),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Skor KPSP · $childName',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Persentase jawaban Ya dalam ${sessions.length} evaluasi terakhir. Garis putus-putus menandai 70% dan 90%.',
                ),
                const SizedBox(height: 24),
                ExcludeSemantics(
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: 100,
                        barGroups: groups,
                        barTouchData: BarTouchData(enabled: false),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            for (final threshold in [70.0, 90.0])
                              HorizontalLine(
                                y: threshold,
                                color: theme.colorScheme.outline,
                                strokeWidth: 1,
                                dashArray: [5, 4],
                              ),
                          ],
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 50,
                              reservedSize: 50,
                              getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}%',
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (v, _) {
                                // Hanya tampilkan label di awal, tengah, akhir
                                // supaya tidak berdesakan di layar sempit.
                                final i = v.toInt();
                                final showLabel = sessions.length <= 3 ||
                                    i == 0 ||
                                    i == sessions.length - 1 ||
                                    i == sessions.length ~/ 2;
                                if (!showLabel) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  DateFormat('d/M').format(
                                    sessions[i].evaluatedAt,
                                  ),
                                  style: theme.textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...details.reversed,
              ],
            );
          },
        );
  }
}
