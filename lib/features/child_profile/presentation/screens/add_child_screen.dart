import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/child_entity.dart';
import '../providers/child_provider.dart';

/// Form untuk menambah data anak baru.
///
/// Desain mengikuti prinsip mobile-design:
/// - DatePicker bukan text input → anti typo tanggal
/// - SegmentedButton untuk gender → 1 tap (bukan Dropdown 2 tap)
/// - Tombol simpan fixed bottom, 56dp → thumb zone
/// - Validation inline → tidak ada dead-end
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _childOrderController = TextEditingController(text: '1');

  DateTime? _selectedBirthDate;
  Gender _selectedGender = Gender.male;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _childOrderController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, now.month, now.day);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih Tanggal Lahir Anak',
      cancelText: 'Batal',
      confirmText: 'OK',
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      _showErrorSnackBar('Pilih tanggal lahir anak terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulasi save — nanti diganti dengan repository call
    await Future.delayed(const Duration(milliseconds: 800));

    final newChild = ChildEntity(
      id: 'child_${DateTime.now().millisecondsSinceEpoch}',
      parentId: 'parent_001', // Mock — nanti dari Firebase Auth
      name: _nameController.text.trim(),
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      childOrder: int.tryParse(_childOrderController.text) ?? 1,
      createdAt: DateTime.now(),
    );

    // Update mock provider
    final children = ref.read(childListProvider);
    ref.read(childListProvider.notifier).state = [...children, newChild];
    ref.read(selectedChildProvider.notifier).state = newChild;

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.goNamed('home');
      _showSuccessSnackBar('Data ${newChild.name} berhasil disimpan');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data Anak'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === NAMA ANAK ===
                    Text(
                      'Nama Anak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama anak',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama anak tidak boleh kosong';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // === TANGGAL LAHIR ===
                    Text(
                      'Tanggal Lahir',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectBirthDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedBirthDate == null
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: _selectedBirthDate == null
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedBirthDate == null
                                  ? 'Pilih tanggal lahir'
                                  : _formatDate(_selectedBirthDate!),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _selectedBirthDate == null
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // === JENIS KELAMIN ===
                    Text(
                      'Jenis Kelamin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<Gender>(
                      segments: const [
                        ButtonSegment(
                          value: Gender.male,
                          label: Text('Laki-laki'),
                          icon: Icon(Icons.boy),
                        ),
                        ButtonSegment(
                          value: Gender.female,
                          label: Text('Perempuan'),
                          icon: Icon(Icons.girl),
                        ),
                      ],
                      selected: {_selectedGender},
                      onSelectionChanged: (Set<Gender> newSelection) {
                        setState(() {
                          _selectedGender = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(
                          const Size.fromHeight(52), // Thumb-friendly
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // === ANAK KE- ===
                    Text(
                      'Anak Ke-',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _childOrderController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        hintText: '1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Urutan anak tidak boleh kosong';
                        }
                        final order = int.tryParse(value);
                        if (order == null || order < 1) {
                          return 'Minimal anak ke-1';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // === INFO HELPER ===
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primaryContainer,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data ini akan digunakan untuk menghitung usia dan menentukan milestone KPSP yang sesuai.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === TOMBOL SIMPAN (FIXED BOTTOM) ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52, // Thumb-friendly
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Data Anak'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
