import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../child_profile/domain/entities/child_entity.dart';
import '../../../child_profile/presentation/providers/child_provider.dart';
import '../../domain/entities/milestone_entity.dart';
import '../providers/milestone_provider.dart';

/// Screen yang menampilkan timeline visual milestone KPSP dari 3-72 bulan.
/// Menunjukkan progress evaluasi per aspek perkembangan.
class MilestoneTimelineScreen extends ConsumerWidget {
  final String childId;

  const MilestoneTimelineScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
          (c) => c?.id == childId,
          orElse: () => null,
        );

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timeline Milestone')),
        body: const Center(child: Text('Data anak tidak ditemukan')),
      );
    }

    final historyAsync = ref.watch(milestoneHistoryStreamProvider(childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Milestone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (history) => _buildContent(context, child, history),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ChildEntity child,
    List<MilestoneResultEntity> history,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Kelompok usia KPSP yang valid
    final kpspAges = [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72];
    
    // Map history by age
    final historyByAge = <int, MilestoneResultEntity>{};
    for (final result in history) {
      historyByAge[result.ageMonthEvaluated] = result;
    }

    // Current age
    final currentAge = child.ageInMonths;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      child.gender == Gender.male ? Icons.boy : Icons.girl,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${child.ageFormatted} • ${child.gender == Gender.male ? "Laki-laki" : "Perempuan"}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildProgressIndicator(context, history, kpspAges, currentAge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Aspect summary
          Text(
            'Ringkasan per Aspek',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAspectSummary(context, history),
          const SizedBox(height: 24),

          // Timeline
          Text(
            'Timeline Evaluasi KPSP',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usia evaluasi: 3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72 bulan',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Timeline items
          ...kpspAges.map((age) => _buildTimelineItem(
                context,
                age,
                historyByAge[age],
                currentAge,
                childId,
              )),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    List<MilestoneResultEntity> history,
    List<int> kpspAges,
    int currentAge,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Count completed evaluations up to current age
    final applicableAges = kpspAges.where((age) => age <= currentAge).length;
    final completedCount = history.length;
    final percentage = applicableAges > 0 
        ? (completedCount / applicableAges * 100).clamp(0, 100)
        : 0.0;

    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 5,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 80
                      ? AppTheme.statusSesuai
                      : percentage >= 50
                          ? AppTheme.statusMeragukan
                          : AppTheme.statusPenyimpangan,
                ),
              ),
              Center(
                child: Text(
                  '${percentage.toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completedCount/$applicableAges',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAspectSummary(
    BuildContext context,
    List<MilestoneResultEntity> history,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate stats per aspect based on answer patterns
    // This is simplified - in real app, would need more detailed tracking
    final aspects = [
      (MilestoneAspect.grossMotor, 'Motorik Kasar', Icons.directions_run),
      (MilestoneAspect.fineMotor, 'Motorik Halus', Icons.pan_tool),
      (MilestoneAspect.speech, 'Bicara & Bahasa', Icons.record_voice_over),
      (MilestoneAspect.social, 'Sosialisasi', Icons.people),
    ];

    // Calculate overall status distribution
    int sesuaiCount = history.where((h) => h.status == MilestoneStatus.sesuai).length;
    int meragukanCount = history.where((h) => h.status == MilestoneStatus.meragukan).length;
    int penyimpanganCount = history.where((h) => h.status == MilestoneStatus.penyimpangan).length;

    return Column(
      children: [
        // Overall status distribution
        if (history.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Sesuai',
                  sesuaiCount,
                  AppTheme.statusSesuai,
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Meragukan',
                  meragukanCount,
                  AppTheme.statusMeragukan,
                  Icons.warning_amber_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Penyimpangan',
                  penyimpanganCount,
                  AppTheme.statusPenyimpangan,
                  Icons.error_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Aspect icons row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: aspects.map((aspect) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    aspect.$3,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aspect.$2,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    int age,
    MilestoneResultEntity? result,
    int currentAge,
    String childId,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPast = age < currentAge;
    final isCurrent = age <= currentAge && age >= currentAge - 2;
    final isFuture = age > currentAge;
    final isCompleted = result != null;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCompleted) {
      switch (result.status) {
        case MilestoneStatus.sesuai:
          statusColor = AppTheme.statusSesuai;
          statusIcon = Icons.check_circle;
          statusText = 'Sesuai (${result.totalYes}/10)';
          break;
        case MilestoneStatus.meragukan:
          statusColor = AppTheme.statusMeragukan;
          statusIcon = Icons.warning_rounded;
          statusText = 'Meragukan (${result.totalYes}/10)';
          break;
        case MilestoneStatus.penyimpangan:
          statusColor = AppTheme.statusPenyimpangan;
          statusIcon = Icons.error_rounded;
          statusText = 'Penyimpangan (${result.totalYes}/10)';
          break;
      }
    } else if (isFuture) {
      statusColor = colorScheme.outline;
      statusIcon = Icons.lock_outline;
      statusText = 'Belum saatnya';
    } else if (isPast && !isCompleted) {
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.schedule;
      statusText = 'Terlewat';
    } else {
      statusColor = colorScheme.primary;
      statusIcon = Icons.play_circle_outline;
      statusText = 'Siap dievaluasi';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? statusColor
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: isCurrent && !isCompleted
                        ? Border.all(color: statusColor, width: 3)
                        : null,
                  ),
                  child: Icon(
                    statusIcon,
                    size: 14,
                    color: isCompleted || (isCurrent && !isFuture)
                        ? colorScheme.surface
                        : colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: isCurrent ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isCurrent
                        ? statusColor
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: (!isFuture && !isCompleted)
                      ? () => context.pushNamed('milestone',
                          pathParameters: {'childId': childId})
                      : isCompleted
                          ? () => _showResultDetail(context, result)
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$age bulan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isFuture
                                    ? colorScheme.outline
                                    : colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Dievaluasi: ${_formatDate(result.evaluatedAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (isCurrent && !isCompleted && !isFuture) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ketuk untuk mulai evaluasi',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDetail(BuildContext context, MilestoneResultEntity result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    String statusTitle;
    String statusDesc;

    switch (result.status) {
      case MilestoneStatus.sesuai:
        statusColor = AppTheme.statusSesuai;
        statusTitle = 'Perkembangan Sesuai';
        statusDesc = 'Anak menunjukkan perkembangan yang baik pada usia ini.';
        break;
      case MilestoneStatus.meragukan:
        statusColor = AppTheme.statusMeragukan;
        statusTitle = 'Perlu Pemantauan';
        statusDesc = 'Perkembangan masih dalam batas wajar, tapi perlu perhatian lebih.';
        break;
      case MilestoneStatus.penyimpangan:
        statusColor = AppTheme.statusPenyimpangan;
        statusTitle = 'Ada Penyimpangan';
        statusDesc = 'Sebaiknya konsultasikan ke dokter atau tenaga kesehatan.';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result.status == MilestoneStatus.sesuai
                        ? Icons.check_circle
                        : result.status == MilestoneStatus.meragukan
                            ? Icons.warning_rounded
                            : Icons.error_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Evaluasi usia ${result.ageMonthEvaluated} bulan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Skor',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${result.totalYes} dari ${result.answers.length} (Ya)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusDesc,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dievaluasi pada ${_formatDate(result.evaluatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
