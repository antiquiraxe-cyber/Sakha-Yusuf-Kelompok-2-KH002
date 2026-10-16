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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _recordDate) {
      setState(() {
        _recordDate = picked;
      });
    }
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

    ref.read(growthRecordsProvider.notifier).addRecord(record);
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

    // Jika ada catatan gizi/fisik khusus (stunting/kurang/obesitas), tampilkan bottom sheet edukatif
    if (eval.hasAlert) {
      await _showEvaluationSheet(context, child?.name ?? 'Si Kecil', eval);
      if (mounted) context.goNamed('home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan pertumbuhan berhasil disimpan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.goNamed('home');
    }
  }

  Future<void> _showEvaluationSheet(
    BuildContext context,
    String childName,
    GrowthEvaluationResult eval,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hasil Pemantauan $childName',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Data telah berhasil disimpan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eval.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eval.summary,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saran Nutrisi & Makanan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ...eval.foodRecommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(rec, style: const TextStyle(fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (eval.foodsToAvoid.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Makanan yang Perlu Dibatasi:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    ...eval.foodsToAvoid.map(
                      (avoid) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✕ ',
                                style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(avoid,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 ${eval.clinicalAction}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Mengerti & Selesai'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  // Tanggal
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pencatatan',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd MMMM yyyy', 'id_ID').format(_recordDate),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
