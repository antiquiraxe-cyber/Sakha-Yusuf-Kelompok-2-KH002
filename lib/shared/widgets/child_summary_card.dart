import 'package:flutter/material.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';

/// Kartu ringkasan anak di dashboard.
/// Menampilkan nama, usia, gender, foto (placeholder), dan status milestone terakhir.
class ChildSummaryCard extends StatelessWidget {
  final ChildEntity child;
  final MilestoneStatus? lastMilestoneStatus;
  final VoidCallback? onTap;

  const ChildSummaryCard({
    super.key,
    required this.child,
    this.lastMilestoneStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Foto/Avatar anak (placeholder circle)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: child.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            child.photoUrl!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Icon(
                                Icons.child_care_rounded,
                                color: colorScheme.onPrimaryContainer,
                              );
                            },
                          ),
                        )
                      : Text(
                          child.gender == Gender.male ? '👦' : '👧',
                          style: const TextStyle(fontSize: 24),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info anak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.ageFormatted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Status milestone
                    _buildMilestoneChip(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneChip(BuildContext context) {
    if (lastMilestoneStatus == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Belum ada evaluasi',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      );
    }

    final (label, color) = switch (lastMilestoneStatus!) {
      MilestoneStatus.sesuai => ('Sesuai ✓', const Color(0xFF43A047)),
      MilestoneStatus.meragukan => ('Meragukan ⚠', const Color(0xFFFFC107)),
      MilestoneStatus.penyimpangan => ('Perlu Perhatian ✗', const Color(0xFFE53935)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Milestone: $label',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
