import 'package:langkahawal/features/tracking/domain/entities/growth_record_entity.dart';

abstract class GrowthRecordRepository {
  Future<List<GrowthRecordEntity>> getRecordsByChildId(String childId);
  Future<void> addRecord(GrowthRecordEntity record);
  Future<void> deleteRecord(String recordId);
}
