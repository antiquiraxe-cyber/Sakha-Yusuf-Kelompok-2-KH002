import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/child_repository_impl.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';

/// Provider untuk instance ChildRepository
final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return ChildRepositoryImpl();
});

/// Stream data anak realtime dari Firestore berdasarkan UID user yang sedang login
final childrenStreamProvider = StreamProvider<List<ChildEntity>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(childRepositoryProvider);
  return repo.watchChildren(user.uid);
});

/// Loading state dari Firestore
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(childrenStreamProvider).isLoading;
});

/// Daftar anak terdaftar (sinkron dengan Firestore)
final childListProvider = Provider<List<ChildEntity>>((ref) {
  return ref.watch(childrenStreamProvider).value ?? [];
});

/// ID anak yang sedang aktif dipilih di dashboard (opsional)
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

/// Objek anak yang sedang dipilih di dashboard
final selectedChildProvider = Provider<ChildEntity?>((ref) {
  final children = ref.watch(childListProvider);
  if (children.isEmpty) return null;

  final selectedId = ref.watch(selectedChildIdProvider);
  if (selectedId == null) return children.first;

  return children.firstWhere(
    (c) => c.id == selectedId,
    orElse: () => children.first,
  );
});
