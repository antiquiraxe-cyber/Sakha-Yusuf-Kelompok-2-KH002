import 'package:flutter/material.dart';
import 'package:langkahawal/core/theme/app_theme.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';

/// Kartu ringkasan anak di dashboard.
/// Menampilkan nama, usia, gender, foto (placeholder), dan status milestone terakhir.
class ChildSummaryCard extends StatelessWidget {
  final ChildEntity child;
  final MilestoneStatus? lastMilestoneStatus;
  const ChildSummaryCard({
    super.key,
    required this.child,
    this.lastMilestoneStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        // Panel cyan lembut seperti kartu utama pada referensi desain.
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Foto/Avatar anak
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: child.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        child.photoUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return const Icon(
                            Icons.child_care_rounded,
                            color: AppTheme.ink,
                          );
                        },
                      ),
                    )
                  : Text(
                      child.gender == Gender.male ? '👦' : '👧',
                      style: const TextStyle(fontSize: 26),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Info anak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  child.ageFormatted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.72,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Status milestone
                _buildMilestoneChip(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneChip(BuildContext context) {
    if (lastMilestoneStatus == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          'Belum ada evaluasi',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.muted,
              ),
        ),
      );
    }

    final (label, color) = switch (lastMilestoneStatus!) {
      MilestoneStatus.sesuai => ('Sesuai ✓', AppTheme.statusSesuai),
      MilestoneStatus.meragukan => ('Meragukan ⚠', AppTheme.statusMeragukan),
      MilestoneStatus.penyimpangan =>
        ('Perlu Perhatian ✗', AppTheme.statusPenyimpangan),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Text(
        'Milestone: $label',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
