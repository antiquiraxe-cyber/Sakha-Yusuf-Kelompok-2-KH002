import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/child_entity.dart';

/// Simulasi loading state untuk dashboard polish.
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Mock provider untuk daftar anak.
/// Nanti diganti dengan Firestore repository di data layer.
/// Kosongkan list untuk test empty state, isi untuk test dashboard.
final childListProvider = StateProvider<List<ChildEntity>>((ref) {
  // --- TEST DATA: uncomment untuk test dashboard dengan data ---
  return [
    ChildEntity(
      id: 'child_001',
      parentId: 'parent_001',
      name: 'Budi',
      birthDate: DateTime(2025, 9, 30),
      gender: Gender.male,
      childOrder: 1,
      createdAt: DateTime.now(),
    ),
  ];

  // --- EMPTY STATE: uncomment untuk test empty state ---
  // return [];
});

/// Provider untuk anak yang sedang aktif/dipilih di dashboard.
final selectedChildProvider = StateProvider<ChildEntity?>((ref) {
  final children = ref.watch(childListProvider);
  return children.isNotEmpty ? children.first : null;
});
