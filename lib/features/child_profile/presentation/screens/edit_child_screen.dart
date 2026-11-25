import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/child_entity.dart';
import '../providers/child_provider.dart';

class EditChildScreen extends ConsumerStatefulWidget {
  final ChildEntity? childData;
  final String? childId;

  const EditChildScreen({
    super.key,
    this.childData,
    this.childId,
  });

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  Gender? _selectedGender;
  bool _isLoading = false;
  bool _initialized = false;
  ChildEntity? _child;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedGender = Gender.male;

    if (widget.childData != null) {
      _initChild(widget.childData!);
    }
  }

  void _initChild(ChildEntity child) {
    _child = child;
    _nameController.text = child.name;
    _selectedDate = child.birthDate;
    _selectedGender = child.gender;
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final target = _child ?? widget.childData;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data profil anak tidak ditemukan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedChild = target.copyWith(
        name: _nameController.text.trim(),
        birthDate: _selectedDate,
        gender: _selectedGender,
      );

      await ref.read(childRepositoryProvider).updateChild(updatedChild);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil anak berhasil diperbarui'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final children = ref.watch(childListProvider);
      final found = children.cast<ChildEntity?>().firstWhere(
            (c) => c?.id == widget.childId,
            orElse: () => null,
          );
      if (found != null) {
        _initChild(found);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil Anak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: _child?.photoUrl != null
                          ? NetworkImage(_child!.photoUrl!)
                          : null,
                      child: _child?.photoUrl == null
                          ? Text(
                              _selectedGender == Gender.female ? '👧' : '👦',
                              style: const TextStyle(fontSize: 44),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fitur foto akan hadir di update berikutnya'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Anak',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Lahir'),
                subtitle: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Gender>(
                key: ValueKey(_child?.id ?? 'gender_field'),
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Gender.male,
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: Gender.female,
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedGender = val);
                  }
                },
                validator: (value) =>
                    value == null ? 'Pilih jenis kelamin' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
