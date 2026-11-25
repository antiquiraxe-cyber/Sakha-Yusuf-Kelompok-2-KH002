import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/child_entity.dart';
import '../providers/child_provider.dart';
import '../providers/reminder_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/child_summary_card.dart';
import '../../../../shared/widgets/animated_entrance.dart';
import '../../../milestone/presentation/providers/milestone_provider.dart';
import '../../../tracking/domain/services/growth_evaluation_service.dart';
import '../../../tracking/presentation/providers/growth_record_provider.dart';
import '../../../tracking/presentation/widgets/growth_evaluation_sheet.dart';

/// Dashboard utama aplikasi LangkahAwal.
///
/// 3 mode tampilan (Reactive State Handling):
/// - Loading State: animasi shimmer skeleton saat mengambil data realtime dari Firestore
/// - Error/Offline State: pesan ramah pengguna jika terjadi kendala jaringan + tombol "Coba Lagi"
/// - Empty State: jika belum ada anak terdaftar → CTA "Tambah Anak"
/// - Dashboard Data: jika data ada → profil, statistik, evaluasi, dan pengingat
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
    final childrenAsync = ref.watch(childrenStreamProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    return childrenAsync.when(
      loading: () =>
          const Scaffold(body: SafeArea(child: DashboardSkeletonLoader())),
      error: (error, stack) => Scaffold(
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
          child: ErrorStateWidget(
            title: 'Gagal Memuat Data',
            message: 'Terjadi kendala saat memuat data anak dari server. Pastikan koneksi internet Anda aktif.',
            actionLabel: 'Coba Lagi',
            onRetry: () => ref.invalidate(childrenStreamProvider),
          ),
        ),
      ),
      data: (children) {
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
                description: 'Tambahkan data anak Anda untuk mulai memantau tumbuh kembangnya secara teratur.',
                actionLabel: 'Tambah Anak',
                onAction: () => context.pushNamed('addChild'),
              ),
            ),
          );
        }

        // Dashboard — ada data anak
        final age = selectedChild!.ageInMonths;
        final period = AppConstants.kpspAgeMonths
            .where((a) => a <= age)
            .lastOrNull;
        final history = ref
            .watch(milestoneHistoryStreamProvider(selectedChild.id))
            .asData
            ?.value;
        final due =
            period != null &&
            age <= AppConstants.kpspAgeMonths.last &&
            history != null &&
            !history.any((result) => result.ageMonthEvaluated == period);
        final reminderAge = due
            ? period
            : AppConstants.kpspAgeMonths.where((a) => a > age).firstOrNull;
        final reminder = _buildReminder(
          context,
          selectedChild,
          ref,
          reminderAge,
          due,
        );
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: center content on wide screens
                final maxWidth = 600.0;
                final horizontalPadding = constraints.maxWidth > maxWidth
                    ? (constraints.maxWidth - maxWidth) / 2
                    : 20.0;

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(childrenStreamProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        minHeight:
                            constraints.maxHeight -
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
                            child: _buildChildSummaryCard(
                              context,
                              selectedChild,
                              ref,
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (due) ...[reminder, const SizedBox(height: 16)],
                          // === GROWTH STATS ROW ===
                          AnimatedEntrance(
                            delay: const Duration(milliseconds: 250),
                            child: _buildGrowthStats(
                              context,
                              selectedChild,
                              ref,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // === GROWTH EVALUATION CARD ===
                          AnimatedEntrance(
                            delay: const Duration(milliseconds: 300),
                            child: _buildGrowthEvaluationCard(
                              context,
                              selectedChild,
                              ref,
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (!due) reminder,
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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

    final displayName = ref.watch(displayNameProvider);
    final greetingTitle = (displayName != null && displayName.isNotEmpty)
        ? '$greeting, $displayName'
        : greeting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Logo gelombang kesehatan, versi sederhana dari referensi.
            CustomPaint(
              size: const Size(38, 38),
              painter: const _HealthMarkPainter(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mari pantau tumbuh kembang Si Kecil hari ini.',
                    style: theme.textTheme.bodySmall?.copyWith(
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
    BuildContext context,
    ChildEntity? child,
    WidgetRef ref,
  ) {
    if (child == null) return const SizedBox.shrink();

    final latestMilestone = ref.watch(latestMilestoneResultProvider(child.id));
    final children = ref.watch(childListProvider);

    return PopupMenuButton<String>(
      tooltip: 'Pilih atau kelola profil anak',
      onSelected: (selection) {
        if (selection.startsWith('child:')) {
          ref.read(selectedChildIdProvider.notifier).state = selection
              .substring('child:'.length);
          return;
        }
        switch (selection) {
          case 'add':
            context.pushNamed('addChild');
          case 'edit':
            context.pushNamed(
              'editChild',
              pathParameters: {'childId': child.id},
              extra: child,
            );
          case 'delete':
            _confirmDeleteChild(context, ref, child);
        }
      },
      itemBuilder: (_) => [
        for (final profile in children)
          CheckedPopupMenuItem<String>(
            checked: profile.id == child.id,
            value: 'child:${profile.id}',
            child: Text(profile.name),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'add', child: Text('Tambah Anak')),
        const PopupMenuItem(value: 'edit', child: Text('Edit profil anak')),
        const PopupMenuItem(value: 'delete', child: Text('Hapus profil anak')),
      ],
      child: ChildSummaryCard(
        child: child,
        lastMilestoneStatus: latestMilestone?.status,
      ),
    );
  }

  Future<void> _confirmDeleteChild(
    BuildContext context,
    WidgetRef ref,
    ChildEntity child,
  ) async {
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
            child: Text(
              'Hapus',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
        }
      }
    }
  }

  Widget _buildGrowthStats(
    BuildContext context,
    ChildEntity? child,
    WidgetRef ref,
  ) {
    if (child == null) return const SizedBox.shrink();

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
            color: AppTheme.metricWeight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.height_outlined,
            label: 'Tinggi',
            value: heightText,
            color: AppTheme.metricHeight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.straighten_outlined,
            label: 'Lingkar Kepala',
            value: headText,
            color: AppTheme.metricHead,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthEvaluationCard(
    BuildContext context,
    ChildEntity? child,
    WidgetRef ref,
  ) {
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
            ],
          ),
        ),
      );
    }

    final eval = GrowthEvaluationService.evaluate(
      ageInMonths: child.ageInMonthsAt(latestRecord.recordDate),
      gender: child.gender,
      weightKg: latestRecord.weightKg,
      heightCm: latestRecord.heightCm,
    );

    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;

    switch (eval.alertLevel) {
      case GrowthAlertLevel.danger:
        statusColor = colorScheme.error;
        statusBg = colorScheme.errorContainer;
        statusIcon = Icons.error_outline_rounded;
        break;
      case GrowthAlertLevel.warning:
        statusColor = AppTheme.statusMeragukan;
        statusBg = AppTheme.coralSoft;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case GrowthAlertLevel.normal:
        statusColor = AppTheme.statusSesuai;
        statusBg = AppTheme.sageSoft;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
    }

    return Card(
      elevation: 0.5,
      color: statusBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: statusColor.withValues(alpha: 0.35)),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'Lihat Saran Gizi & Solusi Nutrisi',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pengingat milestone berikutnya & toggle notifikasi lokal
  Widget _buildReminder(
    BuildContext context,
    ChildEntity child,
    WidgetRef ref,
    int? nextMilestoneAge,
    bool isUrgent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReminderEnabled = ref.watch(reminderProvider);
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
              Icon(
                Icons.notifications_active_outlined,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent ? 'Evaluasi KPSP sudah waktunya' : 'Pengingat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextMilestoneAge != null
                          ? 'Evaluasi milestone usia $nextMilestoneAge bulan untuk ${child.name}.'
                          : 'Tidak ada jadwal evaluasi berikutnya untuk ${child.name}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Buka tab Milestone untuk melakukan evaluasi.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w600,
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
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile.adaptive(
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
                ref
                    .read(reminderProvider.notifier)
                    .toggleReminder(enabled: val, child: child);
              },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppTheme.ink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo gelombang kesehatan berbasis vektor, tanpa aset gambar tambahan.
class _HealthMarkPainter extends CustomPainter {
  const _HealthMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppTheme.ink
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - line.strokeWidth / 2;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, line);

    final wave = Path()
      ..moveTo(size.width * 0.08, size.height * 0.52)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.34,
        size.width * 0.44,
        size.height * 0.68,
        size.width * 0.63,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.39,
        size.width * 0.84,
        size.height * 0.42,
        size.width * 0.93,
        size.height * 0.47,
      );
    final pulse = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.60,
        size.width * 0.43,
        size.height * 0.84,
        size.width * 0.60,
        size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.61,
        size.width * 0.82,
        size.height * 0.64,
        size.width * 0.90,
        size.height * 0.70,
      );
    final cyanLine = Paint()
      ..color = AppTheme.cyan
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(wave, cyanLine);
    canvas.drawPath(pulse, cyanLine);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.width * 0.09,
      Paint()..color = AppTheme.cyan,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.width * 0.09,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
