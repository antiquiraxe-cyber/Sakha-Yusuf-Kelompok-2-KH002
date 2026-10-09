import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Ambil data anak berdasarkan childId dari provider
    final children = ref.watch(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
          (c) => c?.id == widget.childId,
          orElse: () => null,
        );

    // Hitung usia evaluasi KPSP yang tepat
    final evalAgeMonth =
        child == null ? null : KpspQuestionBank.getNearestAge(child.ageInMonths);

    // Anak belum ada atau usianya belum masuk rentang KPSP (< 3 bulan)
    if (evalAgeMonth == null) {
      return _buildUnavailable(context, child);
    }

    final questions = ref.watch(kpspQuestionsProvider(evalAgeMonth));
    final answers = ref.watch(milestoneAnswersProvider);
    final answersNotifier = ref.read(milestoneAnswersProvider.notifier);

    final answeredCount = answers.values.where((v) => v != null).length;
    final totalYes = answers.values.where((v) => v == true).length;
    final isComplete = questions.isNotEmpty && answeredCount == questions.length;
    final progress = questions.isEmpty
        ? 0
        : (answeredCount / questions.length * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi KPSP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Text(
            '$answeredCount/${questions.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
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
                  'Evaluasi milestone usia $evalAgeMonth bulan',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF82),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

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
                  () => _showAnswerDialog(context, q, answersNotifier),
                );
              },
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Summary info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answeredCount == questions.length
                            ? 'Total Ya: $totalYes'
                            : 'Jawab dulu ya',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _getStatusText(totalYes, questions.length,
                            answeredCount == questions.length),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: _getStatusColor(
                                  totalYes, questions.length),
                            ),
                      ),
                    ],
                  ),
                ),

                // Submit button
                if (isComplete)
                  ElevatedButton(
                    onPressed: () => _submitResult(context, totalYes, evalAgeMonth, questions.length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF82),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Lihat Hasil'),
                  )
                else
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Lengkapi Jawaban'),
                  ),
              ],
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
    VoidCallback onAnswer,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAnswered = answer != null;
    final answerText = answer == null
        ? 'Pilih jawaban'
        : answer
            ? 'Ya'
            : 'Tidak';
    final answerColor = answer == null
        ? colorScheme.outline
        : answer
            ? colorScheme.primary
            : colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onAnswer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${question.aspect.toString().split('.')[1]}. ${question.question}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (question.isRedFlag) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_rounded,
                      color: colorScheme.error,
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: answerColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAnswered
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: answerColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      answerText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: answerColor,
                        fontWeight: isAnswered ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAnswerDialog(
    BuildContext context,
    MilestoneQuestionEntity question,
    MilestoneAnswersNotifier answersNotifier,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question.question),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.stimulationTip != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡Tips stimulasi: ${question.stimulationTip}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Answer options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAnswer(
                      context,
                      question.id,
                      answersNotifier,
                      false,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tidak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAnswer(
                      context,
                      question.id,
                      answersNotifier,
                      true,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Ya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAnswer(
    BuildContext context,
    String questionId,
    MilestoneAnswersNotifier answersNotifier,
    bool answer,
  ) {
    answersNotifier.setAnswer(questionId, answer);
    if (mounted) {
      context.pop(); // Close dialog
      HapticFeedback.mediumImpact(); // Subtle vibration feedback
    }
  }

  void _submitResult(
      BuildContext context, int totalYes, int evalAgeMonth, int totalQuestions) {
    final result = MilestoneResultEntity(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      childId: widget.childId,
      ageMonthEvaluated: evalAgeMonth,
      answers: ref
          .read(milestoneAnswersProvider)
          .map((key, value) => MapEntry(key, value ?? false)),
      totalYes: totalYes,
      status: MilestoneResultEntity.calculateStatus(totalYes, totalQuestions),
      evaluatedAt: DateTime.now(),
    );

    // Update last result (mock)
    ref.read(lastMilestoneResultProvider.notifier).state = result;

    // Show result dialog
    showDialog(
      context: context,
      builder: (context) => _ResultDialog(result: result),
    );
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
          onPressed: () => context.pop(),
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
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.goNamed('home'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(int totalYes, int totalQuestions, bool isComplete) {
    if (!isComplete) return 'Jawab semua soal dulu ya';
    final status = MilestoneResultEntity.calculateStatus(totalYes, totalQuestions);
    switch (status) {
      case MilestoneStatus.sesuai:
        return '✅ Sesuai';
      case MilestoneStatus.meragukan:
        return '⚠️ Meragukan';
      case MilestoneStatus.penyimpangan:
        return '❌ Penyimpangan';
    }
  }

  Color _getStatusColor(int totalYes, int totalQuestions) {
    final status = MilestoneResultEntity.calculateStatus(totalYes, totalQuestions);
    switch (status) {
      case MilestoneStatus.sesuai:
        return AppTheme.statusSesuai;
      case MilestoneStatus.meragukan:
        return AppTheme.statusMeragukan;
      case MilestoneStatus.penyimpangan:
        return AppTheme.statusPenyimpangan;
    }
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
        subtitle =
            'Anak menunjukkan perkembangan yang masih dalam batas wajar, tapi perhatikan lebih detail. Konsultasikan ke dokter jika khawatir.';
        statusColor = AppTheme.statusMeragukan;
        break;
      case MilestoneStatus.penyimpangan:
        title = 'Ada Penyimpangan';
        subtitle =
            'Anak menunjukkan perkembangan yang perlu diperhatikan. Sebaiknya segera konsultasikan ke dokter atau tenaga kesehatan.';
        statusColor = AppTheme.statusPenyimpangan;
        break;
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: statusColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            label: 'Catat hasil ini',
            icon: Icons.note_add_rounded,
            onPressed: () => context.pushNamed('tracking',
                pathParameters: {'childId': result.childId}),
          ),
          const SizedBox(height: 8),
          _ResultActionRow(
            label: 'Ulangi evaluasi',
            icon: Icons.refresh_rounded,
            onPressed: () => context.pop(), // Close dialog
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Tutup'),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
