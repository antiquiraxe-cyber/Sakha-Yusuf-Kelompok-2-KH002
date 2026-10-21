import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/growth_record_repository_impl.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../domain/repositories/growth_record_repository.dart';

/// Provider untuk instance GrowthRecordRepository
final growthRecordRepositoryProvider = Provider<GrowthRecordRepository>((ref) {
  return GrowthRecordRepositoryImpl();
});

/// Stream realtime daftar catatan pertumbuhan anak dari Firestore
final growthRecordsStreamProvider =
    StreamProvider.family<List<GrowthRecordEntity>, String>((ref, childId) {
  final repo = ref.watch(growthRecordRepositoryProvider);
  return repo.watchRecords(childId);
});

/// Provider catatan pertumbuhan terbaru untuk seorang anak
final latestGrowthRecordProvider =
    Provider.family<GrowthRecordEntity?, String>((ref, childId) {
  final streamRecords = ref.watch(growthRecordsStreamProvider(childId));
  return streamRecords.maybeWhen(
    data: (records) => records.isEmpty ? null : records.first,
    orElse: () {
      return ref.watch(growthRecordsProvider.notifier).getLatestRecord(childId);
    },
  );
});

/// StateNotifier yang menyinkronkan state lokal dengan repositori Firestore
final growthRecordsProvider =
    StateNotifierProvider<GrowthRecordsNotifier, List<GrowthRecordEntity>>((ref) {
  final repo = ref.watch(growthRecordRepositoryProvider);
  return GrowthRecordsNotifier(repo);
});

class GrowthRecordsNotifier extends StateNotifier<List<GrowthRecordEntity>> {
  final GrowthRecordRepository _repository;

  GrowthRecordsNotifier(this._repository) : super([]);

  // Tambah catatan baru (update state lokal + simpan ke Firestore)
  Future<void> addRecord(GrowthRecordEntity record) async {
    state = [record, ...state];
    try {
      await _repository.addRecord(record);
    } catch (_) {
      // Data tetap aman di state lokal jika offline
    }
  }

  // Ambil catatan berdasarkan childId
  List<GrowthRecordEntity> getRecordsByChildId(String childId) {
    return state.where((record) => record.childId == childId).toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
  }

  // Ambil catatan terbaru untuk anak
  GrowthRecordEntity? getLatestRecord(String childId) {
    final records = getRecordsByChildId(childId);
    return records.isEmpty ? null : records.first;
  }
}

// Loading state untuk operasi penyimpanan
final isSavingRecordProvider = StateProvider<bool>((ref) => false);
