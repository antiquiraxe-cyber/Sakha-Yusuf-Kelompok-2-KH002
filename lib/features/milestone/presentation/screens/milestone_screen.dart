import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/kpsp_question_bank.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../../child_profile/presentation/providers/child_provider.dart';
import '../../../child_profile/domain/entities/child_entity.dart';
import '../providers/milestone_provider.dart';

/// Screen evaluasi KPSP.
/// 10 soal per kelompok usia (Ya/Tidak), hasil: Sesuai/Meragukan/Penyimpangan.
class MilestoneScreen extends ConsumerStatefulWidget {
  final String childId;

  const MilestoneScreen({super.key, required this.childId});

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Ambil data anak berdasarkan childId dari provider
    final children = ref.watch(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
      (c) => c?.id == widget.childId,
      orElse: () => null,
    );

    // Hitung usia evaluasi KPSP yang tepat
    final evalAgeMonth = child == null
        ? null
        : KpspQuestionBank.getNearestAge(child.ageInMonths);

    // Anak belum ada atau usianya belum masuk rentang KPSP (< 3 bulan)
    if (evalAgeMonth == null) {
      return _buildUnavailable(context, child);
    }

    final questions = ref.watch(kpspQuestionsProvider(evalAgeMonth));
    final answersKey = '${widget.childId}:$evalAgeMonth';
    final answers = ref.watch(milestoneAnswersProvider(answersKey));
    final saving = ref.watch(milestoneSavingProvider(answersKey));
    final answersNotifier = ref.read(
      milestoneAnswersProvider(answersKey).notifier,
    );

    final answeredCount = answers.values.where((v) => v != null).length;
    final totalYes = answers.values.where((v) => v == true).length;
    final isComplete =
        questions.isNotEmpty && answeredCount == questions.length;
    final progress = questions.isEmpty
        ? 0
        : (answeredCount / questions.length * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi KPSP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
        ),
        actionsPadding: const EdgeInsetsDirectional.only(end: 16),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_rounded),
            tooltip: 'Timeline Milestone',
            onPressed: () => context.pushNamed(
              'milestoneTimeline',
              pathParameters: {'childId': widget.childId},
            ),
          ),
          Text(
            '$answeredCount/${questions.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${child!.name} · Evaluasi usia $evalAgeMonth bulan',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: colorScheme.outlineVariant),

          // Questions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return _buildQuestionCard(
                  context,
                  q,
                  answers[q.id],
                  saving
                      ? null
                      : (value) => answersNotifier.setAnswer(q.id, value),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isComplete && !saving
                    ? () => _submitResult(
                        totalYes,
                        evalAgeMonth,
                        questions.length,
                      )
                    : null,
                child: Text(
                  saving
                      ? 'Menyimpan…'
                      : isComplete
                      ? 'Simpan hasil evaluasi'
                      : 'Lengkapi ${questions.length - answeredCount} jawaban',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    MilestoneQuestionEntity question,
    bool? answer,
    ValueChanged<bool>? onAnswer,
  ) {
    final aspect = switch (question.aspect) {
      MilestoneAspect.grossMotor => 'Motorik kasar',
      MilestoneAspect.fineMotor => 'Motorik halus',
      MilestoneAspect.speech => 'Bicara dan bahasa',
      MilestoneAspect.social => 'Sosialisasi dan kemandirian',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    aspect,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                if (question.isRedFlag)
                  Icon(
                    Icons.warning_rounded,
                    semanticLabel: 'Perlu perhatian',
                    color: Theme.of(context).colorScheme.error,
                  ),
                if (question.stimulationTip != null)
                  IconButton(
                    tooltip: 'Tips stimulasi',
                    icon: const Icon(Icons.lightbulb_outline),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        scrollable: true,
                        title: const Text('Tips stimulasi'),
                        content: Text(question.stimulationTip!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              question.question,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ya')),
                ButtonSegment(value: false, label: Text('Tidak')),
              ],
              emptySelectionAllowed: true,
              selected: {?answer},
              onSelectionChanged: onAnswer == null
                  ? null
                  : (values) {
                      if (values.isNotEmpty) onAnswer(values.first);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitResult(
    int totalYes,
    int evalAgeMonth,
    int totalQuestions,
  ) async {
    final key = '${widget.childId}:$evalAgeMonth';
    final saving = ref.read(milestoneSavingProvider(key).notifier);
    if (saving.state) return;
    final answers = ref.read(milestoneAnswersProvider(key).notifier);
    saving.state = true;
    final result = MilestoneResultEntity(
      id: answers.submissionId,
      childId: widget.childId,
      ageMonthEvaluated: evalAgeMonth,
      answers: ref
          .read(milestoneAnswersProvider('${widget.childId}:$evalAgeMonth'))
          .map((key, value) => MapEntry(key, value ?? false)),
      totalYes: totalYes,
      status: MilestoneResultEntity.calculateStatus(totalYes, totalQuestions),
      evaluatedAt: DateTime.now(),
    );

    try {
      await ref.read(milestoneRepositoryProvider).saveMilestoneResult(result);
      answers.reset();
    } catch (_) {
      if (mounted && widget.childId == result.childId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Hasil gagal disimpan. Jawaban masih tersedia. Tekan simpan untuk mencoba lagi.',
            ),
          ),
        );
      }
      return;
    } finally {
      saving.state = false;
    }
    if (!mounted ||
        widget.childId != result.childId ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    final destination = await showDialog<String>(
      context: context,
      builder: (context) => _ResultDialog(result: result),
    );
    if (mounted && destination != null) {
      context.pushNamed(
        destination,
        pathParameters: {'childId': result.childId},
      );
    }
  }

  /// Tampilan saat evaluasi tidak bisa dilakukan
  /// (anak tidak ditemukan, atau usia < 3 bulan).
  Widget _buildUnavailable(BuildContext context, ChildEntity? child) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi KPSP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                child == null
                    ? 'Data anak tidak ditemukan'
                    : 'Belum waktunya evaluasi KPSP',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                child == null
                    ? 'Silakan kembali ke beranda dan pilih data anak.'
                    : '${child.name} baru ${child.ageFormatted}. Evaluasi KPSP dimulai saat usia 3 bulan.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog hasil evaluasi
class _ResultDialog extends StatelessWidget {
  final MilestoneResultEntity result;

  const _ResultDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    String title;
    String subtitle;
    Color statusColor;

    switch (result.status) {
      case MilestoneStatus.sesuai:
        title = 'Tumbuh Kembang Sesuai';
        subtitle = 'Anak menunjukkan perkembangan yang baik. Terus stimulasi dan perhatikan kebutuhan gizinya.';
        statusColor = AppTheme.statusSesuai;
        break;
      case MilestoneStatus.meragukan:
        title = 'Perlu Pemantauan Lebih';
        subtitle = 'Anak menunjukkan perkembangan yang masih dalam batas wajar, tapi perhatikan lebih detail. Konsultasikan ke dokter jika khawatir.';
        statusColor = AppTheme.statusMeragukan;
        break;
      case MilestoneStatus.penyimpangan:
        title = 'Ada Penyimpangan';
        subtitle = 'Anak menunjukkan perkembangan yang perlu diperhatikan. Sebaiknya segera konsultasikan ke dokter atau tenaga kesehatan.';
        statusColor = AppTheme.statusPenyimpangan;
        break;
    }

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: statusColor, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hasil tersimpan'),
          Text(
            'Skor: ${result.totalYes} dari ${result.answers.length} (Ya)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ResultActionRow(
            label: 'Catat pertumbuhan',
            icon: Icons.note_add_rounded,
            onPressed: () => Navigator.pop(context, 'tracking'),
          ),
          const SizedBox(height: 8),
          _ResultActionRow(
            label: 'Lihat riwayat KPSP',
            icon: Icons.history_rounded,
            onPressed: () => Navigator.pop(context, 'milestoneTimeline'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Tutup')),
      ],
    );
  }
}

/// Row tombol aksi hasil dialog
class _ResultActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ResultActionRow({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
