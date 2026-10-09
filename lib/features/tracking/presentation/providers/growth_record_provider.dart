import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/growth_record_entity.dart';

// Mock data growth records
final growthRecordsProvider = StateNotifierProvider<GrowthRecordsNotifier, List<GrowthRecordEntity>>((ref) {
  return GrowthRecordsNotifier();
});

class GrowthRecordsNotifier extends StateNotifier<List<GrowthRecordEntity>> {
  GrowthRecordsNotifier() : super([]);

  // Add new record
  void addRecord(GrowthRecordEntity record) {
    state = [...state, record];
  }

  // Get records by childId
  List<GrowthRecordEntity> getRecordsByChildId(String childId) {
    return state.where((record) => record.childId == childId).toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate)); // newest first
  }

  // Get latest record for a child
  GrowthRecordEntity? getLatestRecord(String childId) {
    final records = getRecordsByChildId(childId);
    return records.isEmpty ? null : records.first;
  }
}

// Loading state for save operation
final isSavingRecordProvider = StateProvider<bool>((ref) => false);
