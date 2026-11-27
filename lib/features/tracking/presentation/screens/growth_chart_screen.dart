import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../child_profile/domain/entities/child_entity.dart';
import '../../../child_profile/presentation/providers/child_provider.dart';
import '../../domain/entities/growth_metric.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../providers/growth_record_provider.dart';
import '../data/who_growth_standards.dart';
import '../widgets/kpsp_progress_chart.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  final String childId;

  const GrowthChartScreen({super.key, required this.childId});

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
      (c) => c?.id == widget.childId,
      orElse: () => null,
    );

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grafik Tumbuh Kembang')),
        body: const Center(child: Text('Data anak tidak ditemukan')),
      );
    }

    final recordsAsync = ref.watch(growthRecordsStreamProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Tumbuh Kembang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Berat Badan'),
            Tab(text: 'Tinggi Badan'),
            Tab(text: 'Lingkar Kepala'),
            Tab(text: 'KPSP'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final tab in GrowthChartTab.values)
            recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ErrorStateWidget(
                onRetry: () =>
                    ref.invalidate(growthRecordsStreamProvider(child.id)),
              ),
              data: (records) => records.isEmpty
                  ? _buildEmptyState(context)
                  : _buildChartView(context, child, records, tab),
            ),
          KpspProgressChart(childId: child.id, childName: child.name),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Belum ada data pertumbuhan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Catat pertumbuhan anak untuk melihat grafik',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            'Buka tab Catatan untuk menambah data pertumbuhan.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(
    BuildContext context,
    ChildEntity child,
    List<GrowthRecordEntity> records,
    GrowthChartTab tab,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort records by date
    final sortedRecords = List<GrowthRecordEntity>.from(records)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    // Get chart title and unit
    String title;
    String unit;
    Color lineColor;

    switch (tab) {
      case GrowthChartTab.weight:
        title = 'Berat Badan';
        unit = 'kg';
        lineColor = colorScheme.primary;
        break;
      case GrowthChartTab.height:
        title = 'Tinggi Badan';
        unit = 'cm';
        lineColor = AppTheme.metricHeight;
        break;
      case GrowthChartTab.headCircumference:
        title = 'Lingkar Kepala';
        unit = 'cm';
        lineColor = AppTheme.metricHead;
        break;
    }

    // Generate data points
    final dataPoints = <FlSpot>[];
    for (final record in sortedRecords) {
      final ageInMonths = _calculateAgeAtRecord(
        child.birthDate,
        record.recordDate,
      );
      double? value;

      switch (tab) {
        case GrowthChartTab.weight:
          value = record.weightKg;
          break;
        case GrowthChartTab.height:
          value = record.heightCm;
          break;
        case GrowthChartTab.headCircumference:
          value = record.headCircumferenceCm;
          break;
      }

      if (value != null && ageInMonths >= 0 && ageInMonths <= 60) {
        dataPoints.add(FlSpot(ageInMonths.toDouble(), value));
      }
    }

    if (dataPoints.isEmpty) {
      return Center(
        child: Text('Tidak ada data $title', style: theme.textTheme.bodyLarge),
      );
    }

    final previous = dataPoints.length > 1
        ? dataPoints[dataPoints.length - 2].y
        : null;
    final change = previous == null ? null : dataPoints.last.y - previous;

    // Get WHO standards
    final whoStandards = WhoGrowthStandards.getStandards(tab, child.gender);

    // Calculate Y axis range
    final allValues = [
      ...dataPoints.map((p) => p.y),
      ...whoStandards.p3.map((p) => p.y),
      ...whoStandards.p97.map((p) => p.y),
    ];
    final minY = (allValues.reduce((a, b) => a < b ? a : b) * 0.9)
        .floorToDouble();
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) * 1.1)
        .ceilToDouble();

    // Calculate X axis range based on data
    final minX = 0.0;
    final maxX =
        (dataPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b) + 6).clamp(
          12.0,
          60.0,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.child_care, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          child.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usia: ${child.ageFormatted} • ${child.gender == Gender.male ? "Laki-laki" : "Perempuan"}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (dataPoints.isNotEmpty) ...[
                    const Divider(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildStatItem(
                          context,
                          'Terakhir',
                          '${dataPoints.last.y.toStringAsFixed(1)} $unit',
                          lineColor,
                        ),
                        if (change != null)
                          _buildStatItem(
                            context,
                            'Sejak catatan sebelumnya',
                            '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} $unit',
                            colorScheme.onSurface,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (dataPoints.length == 1)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Butuh minimal 2 catatan untuk melihat tren.'),
            ),
          // Legend
          _buildLegend(context, lineColor),
          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: (maxY - minY) / 5,
                  verticalInterval: 6,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Usia (bulan)'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text('$title ($unit)'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxY - minY) / 5,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                lineBarsData: [
                  // WHO P97 (upper bound)
                  _buildWhoLine(
                    whoStandards.p97,
                    colorScheme.error.withValues(alpha: 0.45),
                    maxX,
                  ),
                  // WHO P50 (median)
                  _buildWhoLine(
                    whoStandards.p50,
                    colorScheme.primary.withValues(alpha: 0.5),
                    maxX,
                  ),
                  // WHO P3 (lower bound)
                  _buildWhoLine(
                    whoStandards.p3,
                    colorScheme.error.withValues(alpha: 0.45),
                    maxX,
                  ),
                  // Child's data
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: colorScheme.surface,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => colorScheme.surface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 3) {
                          // Child's data line
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} $unit\n(${spot.x.toInt()} bulan)',
                            TextStyle(
                              color: lineColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data points list
          Text(
            'Riwayat Pengukuran',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedRecords.reversed.take(5).map((record) {
            double? value;
            switch (tab) {
              case GrowthChartTab.weight:
                value = record.weightKg;
                break;
              case GrowthChartTab.height:
                value = record.heightCm;
                break;
              case GrowthChartTab.headCircumference:
                value = record.headCircumferenceCm;
                break;
            }

            if (value == null) return const SizedBox.shrink();

            final ageAtRecord = _calculateAgeAtRecord(
              child.birthDate,
              record.recordDate,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: lineColor.withValues(alpha: 0.1),
                  child: Icon(Icons.straighten, color: lineColor, size: 20),
                ),
                title: Text('${value.toStringAsFixed(1)} $unit'),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy', 'id_ID').format(record.recordDate)} • $ageAtRecord bulan',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, Color lineColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(context, 'Data Anak', lineColor),
        _buildLegendItem(
          context,
          'Median WHO',
          colorScheme.primary.withValues(alpha: 0.5),
        ),
        _buildLegendItem(
          context,
          'Batas Normal (P3-P97)',
          colorScheme.error.withValues(alpha: 0.45),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  LineChartBarData _buildWhoLine(List<FlSpot> spots, Color color, double maxX) {
    // Filter spots to maxX
    final filteredSpots = spots.where((s) => s.x <= maxX).toList();

    return LineChartBarData(
      spots: filteredSpots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 1.5,
      dotData: const FlDotData(show: false),
      dashArray: [5, 5],
    );
  }

  int _calculateAgeAtRecord(DateTime birthDate, DateTime recordDate) {
    int months =
        (recordDate.year - birthDate.year) * 12 +
        (recordDate.month - birthDate.month);
    if (recordDate.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }
}
