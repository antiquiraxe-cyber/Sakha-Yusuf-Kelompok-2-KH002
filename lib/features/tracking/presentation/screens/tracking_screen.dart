import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/animated_entrance.dart';
import '../providers/growth_record_provider.dart';
import '../../domain/entities/growth_record_entity.dart';
import 'package:intl/intl.dart';

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
    );
    if (picked != null && picked != _recordDate) {
      setState(() {
        _recordDate = picked;
      });
    }
  }

  void _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      ref.read(isSavingRecordProvider.notifier).state = true;
      
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      final record = GrowthRecordEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.childId,
        recordDate: _recordDate,
        weightKg: double.parse(_weightController.text),
        heightCm: double.parse(_heightController.text),
        headCircumferenceCm: _headController.text.isNotEmpty ? double.parse(_headController.text) : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
      );

      ref.read(growthRecordsProvider.notifier).addRecord(record);
      ref.read(isSavingRecordProvider.notifier).state = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan pertumbuhan berhasil disimpan')),
        );
        context.goNamed('home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingRecordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Pertumbuhan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'), // Kembali ke home
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Tinggi Badan
                  TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingL),

                  // Lingkar Kepala (Opsional)
                  TextFormField(
                    controller: _headController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Tambahan (Opsional)',
                      hintText: 'Misal: Anak sedang flu...',
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
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : const Icon(Icons.save),
                    label: Text(isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56), // Hit target ≥48dp
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