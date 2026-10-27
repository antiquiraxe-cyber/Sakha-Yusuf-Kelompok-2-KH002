import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/child_entity.dart';
import '../providers/child_provider.dart';
import '../providers/reminder_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/child_summary_card.dart';
import '../../../../shared/widgets/animated_entrance.dart';
import '../../../milestone/presentation/providers/milestone_provider.dart';
import '../../../tracking/domain/services/growth_evaluation_service.dart';
import '../../../tracking/presentation/providers/growth_record_provider.dart';
import '../../../tracking/presentation/widgets/growth_evaluation_sheet.dart';

/// Dashboard utama aplikasi LangkahAwal.
///
/// 2 mode:
/// - Empty State: belum ada data anak → CTA "Tambah Anak"
/// - Dashboard: ada data anak → summary card + stats + quick actions + pengingat
///
/// Desain mengikuti prinsip mobile-design skill:
/// - Thumb Zone: tombol aksi utama di area bawah layar
/// - Hit Target ≥ 48dp: semua tombol interaktif minimal 48dp
/// - Progressive Disclosure: info ringkas dulu, detail di screen lain
/// - Responsive: max-width constraint untuk web/desktop
class ChildListScreen extends ConsumerWidget {
  const ChildListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childListProvider);
    final selectedChild = ref.watch(selectedChildProvider);
    final isLoading = ref.watch(isLoadingProvider);

    // Loading skeleton saat pertama kali ambil data dari Firestore
    if (isLoading) {
      return Scaffold(
        body: SafeArea(
          child: _buildLoadingSkeleton(context),
        ),
      );
    }

    // Empty state — belum ada anak
    if (children.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Keluar',
              onPressed: () => _confirmSignOut(context, ref),
            ),
          ],
        ),
        body: SafeArea(
          child: EmptyStateWidget(
            icon: Icons.child_care,
            title: 'Mulai Pantau Si Kecil',
            description:
                'Tambahkan data anak Anda untuk mulai memantau tumbuh kembangnya secara teratur.',
            actionLabel: 'Tambah Anak',
            onAction: () => context.pushNamed('addChild'),
          ),
        ),
      );
    }

    // Dashboard — ada data anak
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: center content on wide screens
            final maxWidth = 600.0;
            final horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2
                : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minHeight: constraints.maxHeight -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // === GREETING HEADER ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 50),
                      child: _buildGreetingHeader(context, ref),
                    ),

                    const SizedBox(height: 20),

                    // === CHILD SUMMARY CARD ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 150),
                      child: _buildChildSummaryCard(context, selectedChild, ref),
                    ),

                    const SizedBox(height: 20),

                    // === GROWTH STATS ROW ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 250),
                      child: _buildGrowthStats(context, selectedChild, ref),
                    ),

                    const SizedBox(height: 16),

                    // === GROWTH EVALUATION CARD ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 300),
                      child: _buildGrowthEvaluationCard(
                          context, selectedChild, ref),
                    ),

                    const SizedBox(height: 20),

                    // === QUICK ACTIONS ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 350),
                      child: _buildQuickActions(context, selectedChild, ref),
                    ),

                    const SizedBox(height: 20),

                    // === REMINDER CARD ===
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 450),
                      child: _buildReminder(context, selectedChild, ref),
                    ),

                    const SizedBox(height: 24), // Bottom padding for FAB space
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('addChild'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anak'),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGreetingHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : 'Selamat Sore';

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final greetingTitle = (displayName != null && displayName.isNotEmpty)
        ? '$greeting, $displayName'
        : greeting;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mari pantau tumbuh kembang Si Kecil hari ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Keluar Akun',
          onPressed: () => _confirmSignOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        context.goNamed('login');
      }
    }
  }

 Widget _buildChildSummaryCard(
      BuildContext context, ChildEntity? child, WidgetRef ref) {
    if (child == null) return const SizedBox.shrink();

    final latestMilestone = ref.watch(latestMilestoneResultProvider(child.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profil Anak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  tooltip: 'Edit Profil Anak',
                  onPressed: () {
                    context.pushNamed(
                      'editChild',
                      pathParameters: {'childId': child.id},
                      extra: child,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus Profil Anak',
                  onPressed: () => _confirmDeleteChild(context, ref, child),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ChildSummaryCard(
          child: child,
          lastMilestoneStatus: latestMilestone?.status,
          onTap: () => context.pushNamed('milestone',
              pathParameters: {'childId': child.id}),
        ),
      ],
    );
  }

Future<void> _confirmDeleteChild(
      BuildContext context, WidgetRef ref, ChildEntity child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Profil Anak'),
        content: Text('Hapus ${child.name}? Data akan hilang permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await ref.read(childRepositoryProvider).deleteChild(uid, child.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data ${child.name} berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus data: $e')),
          );
        }
      }
    }
  }
  
  Widget _buildGrowthStats(
      BuildContext context, ChildEntity? child, WidgetRef ref) {
    if (child == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final latestRecord = ref.watch(latestGrowthRecordProvider(child.id));

    final weightText = latestRecord != null
        ? '${latestRecord.weightKg.toStringAsFixed(1)} kg'
        : '— kg';
    final heightText = latestRecord != null
        ? '${latestRecord.heightCm.toStringAsFixed(1)} cm'
        : '— cm';
    final headText = (latestRecord?.headCircumferenceCm != null)
        ? '${latestRecord!.headCircumferenceCm!.toStringAsFixed(1)} cm'
        : '— cm';

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.monitor_weight_outlined,
            label: 'Berat',
            value: weightText,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.height_outlined,
            label: 'Tinggi',
            value: heightText,
            color: const Color(0xFFFFA726),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.straighten_outlined,
            label: 'Lingkar Kepala',
            value: headText,
            color: const Color(0xFF43A047),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthEvaluationCard(
      BuildContext context, ChildEntity? child, WidgetRef ref) {
    if (child == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final latestRecord = ref.watch(latestGrowthRecordProvider(child.id));

    if (latestRecord == null) {
      return Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.pushNamed(
            'tracking',
            pathParameters: {'childId': child.id},
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_chart_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum Ada Catatan Fisik',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Catat berat & tinggi badan si kecil untuk evaluasi gizi.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      );
    }

    final eval = GrowthEvaluationService.evaluate(
      ageInMonths: child.ageInMonths,
      gender: child.gender,
      weightKg: latestRecord.weightKg,
      heightCm: latestRecord.heightCm,
    );

    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;

    switch (eval.alertLevel) {
      case GrowthAlertLevel.danger:
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        statusIcon = Icons.error_outline_rounded;
        break;
      case GrowthAlertLevel.warning:
        statusColor = Colors.orange.shade800;
        statusBg = Colors.orange.shade50;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case GrowthAlertLevel.normal:
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
    }

    return Card(
      elevation: 0.5,
      color: statusBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showGrowthEvaluationSheet(
          context,
          childName: child.name,
          eval: eval,
          subtitle:
              'Catatan Terakhir • ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(latestRecord.recordDate)} WIB',
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eval.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Terbaru',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                eval.summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade800,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Saran Gizi & Solusi Nutrisi',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ChildEntity? child, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return Row(
      children: [
        // Tombol Cek Milestone
        Expanded(
          child: _QuickActionButton(
            icon: Icons.checklist_rounded,
            label: 'Cek\nMilestone',
            color: const Color(0xFF4CAF82),
            isLoading: isLoading,
            onTap: () {
              if (child != null && !isLoading) {
                context.goNamed('milestone',
                    pathParameters: {'childId': child.id});
              }
            },
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Catat Tumbuh Kembang
        Expanded(
          child: _QuickActionButton(
            icon: Icons.edit_note_rounded,
            label: 'Catat\nTumbuh Kembang',
            color: const Color(0xFFFFA726),
            isLoading: isLoading,
            onTap: () {
              if (child != null && !isLoading) {
                context.goNamed('tracking',
                    pathParameters: {'childId': child.id});
              }
            },
          ),
        ),
      ],
    );
  }

  /// Pengingat milestone berikutnya & toggle notifikasi lokal
  Widget _buildReminder(
      BuildContext context, ChildEntity? child, WidgetRef ref) {
    if (child == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReminderEnabled = ref.watch(reminderProvider);

    // Hitung milestone berikutnya berdasarkan usia
    final ageMonths = child.ageInMonths;
    final nextMilestoneAge = _getNextMilestoneAge(ageMonths);

    // Highlight kalau milestone dekat (age >= 80% next milestone)
    final isUrgent = nextMilestoneAge != null &&
        ageMonths >= (nextMilestoneAge * 0.8);

    final containerColor = isUrgent
        ? colorScheme.errorContainer.withValues(alpha: 0.3)
        : colorScheme.tertiaryContainer.withValues(alpha: 0.3);
    final borderColor = isUrgent
        ? colorScheme.errorContainer
        : colorScheme.tertiaryContainer;
    final iconColor = isUrgent ? colorScheme.error : colorScheme.tertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active_outlined,
                  color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent ? 'Evaluasi Mendekat!' : 'Pengingat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextMilestoneAge != null
                          ? 'Evaluasi milestone usia $nextMilestoneAge bulan untuk ${child.name}.'
                          : '${child.name} sudah melewati semua rentang usia KPSP. Tetap pantau perkembangannya!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => context.pushNamed('milestone',
                              pathParameters: {'childId': child.id}),
                          icon: const Icon(Icons.assignment_outlined, size: 18),
                          label: const Text('Lakukan Sekarang'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Ingatkan Evaluasi KPSP',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              isReminderEnabled
                  ? 'Pengingat otomatis aktif'
                  : 'Aktifkan notifikasi pengingat di HP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: isReminderEnabled,
            activeThumbColor: colorScheme.primary,
            onChanged: (val) {
              ref.read(reminderProvider.notifier).toggleReminder(
                    enabled: val,
                    child: child,
                  );
            },
          ),
        ],
      ),
    );
  }

  /// Cari usia milestone KPSP berikutnya berdasarkan usia anak saat ini.
  int? _getNextMilestoneAge(int currentAgeMonths) {
    const kpspAges = [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60];
    for (final age in kpspAges) {
      if (age >= currentAgeMonths) return age;
    }
    return null; // Anak sudah > 60 bulan
  }

  /// Loading skeleton untuk state loading
  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting skeleton
          _SkeletonLine(width: 120, height: 24),
          const SizedBox(height: 8),
          _SkeletonLine(width: 200, height: 16),
          const SizedBox(height: 24),

          // Child card skeleton
          _SkeletonCard(
            child: Row(
              children: [
                _SkeletonCircle(size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 100, height: 20),
                      const SizedBox(height: 8),
                      _SkeletonLine(width: 150, height: 14),
                      const SizedBox(height: 8),
                      _SkeletonLine(width: 80, height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats skeleton
          Row(
            children: [
              Expanded(child: _SkeletonCard(child: _SkeletonLine(width: 60, height: 40))),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonCard(child: _SkeletonLine(width: 60, height: 40))),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonCard(child: _SkeletonLine(width: 60, height: 40))),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions skeleton
          Row(
            children: [
              Expanded(child: _SkeletonCard(child: _SkeletonLine(width: 80, height: 80))),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonCard(child: _SkeletonLine(width: 80, height: 80))),
            ],
          ),
          const SizedBox(height: 20),

          // Reminder skeleton
          _SkeletonCard(
            child: Row(
              children: [
                _SkeletonCircle(size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 80, height: 18),
                      const SizedBox(height: 8),
                      _SkeletonLine(width: double.infinity, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile statistik tumbuh kembang (ringkas)
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Tombol aksi cepat — besar, thumb-friendly, min height 96dp.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton line untuk loading state
class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton circle untuk loading state
class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton card wrapper
class _SkeletonCard extends StatelessWidget {
  final Widget child;

  const _SkeletonCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}