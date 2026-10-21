import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/animated_entrance.dart';
import '../../../child_profile/domain/entities/child_entity.dart';
import '../../../child_profile/presentation/providers/child_provider.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../domain/services/growth_evaluation_service.dart';
import '../providers/growth_record_provider.dart';
import '../widgets/growth_evaluation_sheet.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String childId;

  const TrackingScreen({super.key, required this.childId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _recordDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordDate),
    );

    if (!mounted) return;

    final hour = pickedTime?.hour ?? _recordDate.hour;
    final minute = pickedTime?.minute ?? _recordDate.minute;

    setState(() {
      _recordDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        hour,
        minute,
      );
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(isSavingRecordProvider.notifier).state = true;

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    // Simpan data terlebih dahulu agar data ibu aman
    final record = GrowthRecordEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: widget.childId,
      recordDate: _recordDate,
      weightKg: weight,
      heightCm: height,
      headCircumferenceCm: _headController.text.isNotEmpty
          ? double.tryParse(_headController.text)
          : null,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    await ref.read(growthRecordsProvider.notifier).addRecord(record);
    ref.read(isSavingRecordProvider.notifier).state = false;

    if (!mounted) return;

    // Evaluasi pertumbuhan secara tenang setelah data tersimpan
    final children = ref.read(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
          (c) => c?.id == widget.childId,
          orElse: () => null,
        );

    final eval = GrowthEvaluationService.evaluate(
      ageInMonths: child?.ageInMonths ?? 12,
      gender: child?.gender ?? Gender.male,
      weightKg: weight,
      heightCm: height,
    );

    // Tampilkan bottom sheet edukatif hasil evaluasi & panduan nutrisi
    await showGrowthEvaluationSheet(
      context,
      childName: child?.name ?? 'Si Kecil',
      eval: eval,
      subtitle: 'Data telah berhasil disimpan',
    );
    if (mounted) context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingRecordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Pertumbuhan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          child: AnimatedEntrance(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tanggal & Jam Pencatatan
                  InkWell(
                    onTap: _selectDateTime,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Waktu Pencatatan',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        suffixIcon: Icon(Icons.edit_calendar_outlined, size: 20),
                      ),
                      child: Text(
                        '${DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(_recordDate)} WIB',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Berat Badan
                  TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      hintText: 'Contoh: 10.5',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                      suffixText: 'kg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Berat badan harus diisi';
                      }
                      final v = double.tryParse(value);
                      if (v == null || v <= 0) {
                        return 'Masukkan angka berat badan yang valid (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Tinggi Badan
                  TextFormField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tinggi/Panjang Badan (cm)',
                      hintText: 'Contoh: 75.0',
                      prefixIcon: Icon(Icons.height),
                      suffixText: 'cm',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tinggi badan harus diisi';
                      }
                      final v = double.tryParse(value);
                      if (v == null || v <= 0) {
                        return 'Masukkan angka tinggi badan yang valid (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Lingkar Kepala (Opsional)
                  TextFormField(
                    controller: _headController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Lingkar Kepala (cm) - Opsional',
                      hintText: 'Contoh: 45.0',
                      prefixIcon: Icon(Icons.face),
                      suffixText: 'cm',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Catatan (Opsional)
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Tambahan (Opsional)',
                      hintText: 'Misal: Anak sedang tumbuh gigi...',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXL),

                  // Submit Button
                  FilledButton.icon(
                    onPressed: isSaving ? null : _saveRecord,
                    icon: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),

                  const SizedBox(height: AppTheme.paddingXL),
                  _buildHistorySection(context, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(growthRecordsStreamProvider(widget.childId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final children = ref.watch(childListProvider);
    final child = children.cast<ChildEntity?>().firstWhere(
          (c) => c?.id == widget.childId,
          orElse: () => null,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pertumbuhan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.history_rounded, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Gagal memuat riwayat: $err',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
          data: (records) {
            if (records.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.monitor_weight_outlined,
                        size: 36, color: colorScheme.outline),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada riwayat timbangan',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: records.map((record) {
                final eval = GrowthEvaluationService.evaluate(
                  ageInMonths: child?.ageInMonths ?? 12,
                  gender: child?.gender ?? Gender.male,
                  weightKg: record.weightKg,
                  heightCm: record.heightCm,
                );

                final Color statusBadgeBg;
                final Color statusBadgeColor;
                final String statusBadgeLabel;
                final IconData statusBadgeIcon;

                switch (eval.alertLevel) {
                  case GrowthAlertLevel.danger:
                    statusBadgeBg = Colors.red.shade50;
                    statusBadgeColor = Colors.red.shade700;
                    statusBadgeIcon = Icons.error_outline_rounded;
                    statusBadgeLabel = eval.stuntingStatus == StuntingStatus.severelyStunted
                        ? 'Sangat Pendek'
                        : (eval.weightStatus == WeightStatus.obese
                            ? 'Obesitas'
                            : (eval.weightStatus == WeightStatus.severelyUnderweight
                                ? 'Gizi Buruk'
                                : 'Peringatan'));
                    break;
                  case GrowthAlertLevel.warning:
                    statusBadgeBg = Colors.orange.shade50;
                    statusBadgeColor = Colors.orange.shade800;
                    statusBadgeIcon = Icons.warning_amber_rounded;
                    statusBadgeLabel = eval.stuntingStatus == StuntingStatus.stunted
                        ? 'Pendek'
                        : (eval.weightStatus == WeightStatus.underweight
                            ? 'Gizi Kurang'
                            : (eval.weightStatus == WeightStatus.overweightRisk
                                ? 'Risiko Lebih'
                                : 'Waspada'));
                    break;
                  case GrowthAlertLevel.normal:
                    statusBadgeBg = Colors.green.shade50;
                    statusBadgeColor = Colors.green.shade700;
                    statusBadgeIcon = Icons.check_circle_outline_rounded;
                    statusBadgeLabel = 'Normal';
                    break;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showGrowthEvaluationSheet(
                      context,
                      childName: child?.name ?? 'Si Kecil',
                      eval: eval,
                      subtitle:
                          'Catatan: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(record.recordDate)} WIB',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(record.recordDate)} WIB',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.redAccent),
                                tooltip: 'Hapus Catatan',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    _confirmDeleteRecord(record.id),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildHistoryBadge(
                                context,
                                icon: Icons.monitor_weight_outlined,
                                label: 'BB: ${record.weightKg.toStringAsFixed(1)} kg',
                                color: colorScheme.primary,
                              ),
                              _buildHistoryBadge(
                                context,
                                icon: Icons.height,
                                label: 'TB: ${record.heightCm.toStringAsFixed(1)} cm',
                                color: const Color(0xFFFFA726),
                              ),
                              if (record.headCircumferenceCm != null)
                                _buildHistoryBadge(
                                  context,
                                  icon: Icons.face,
                                  label:
                                      'LK: ${record.headCircumferenceCm!.toStringAsFixed(1)} cm',
                                  color: const Color(0xFF43A047),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBadgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: statusBadgeColor
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusBadgeIcon,
                                        size: 13, color: statusBadgeColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusBadgeLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: statusBadgeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (record.note != null && record.note!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Catatan: ${record.note}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Hasil & Rekomendasi Gizi',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 11, color: colorScheme.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRecord(String recordId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan pertumbuhan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref
            .read(growthRecordRepositoryProvider)
            .deleteRecord(widget.childId, recordId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan pertumbuhan berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus catatan: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
