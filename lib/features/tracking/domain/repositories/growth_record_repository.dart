import '../entities/growth_record_entity.dart';

abstract class GrowthRecordRepository {
  /// Memantau seluruh catatan pertumbuhan anak secara realtime
  Stream<List<GrowthRecordEntity>> watchRecords(String childId);

  /// Mengambil daftar catatan pertumbuhan anak
  Future<List<GrowthRecordEntity>> getRecordsByChildId(String childId);

  /// Mengambil catatan pertumbuhan paling terbaru untuk seorang anak
  Future<GrowthRecordEntity?> getLatestRecord(String childId);

  /// Menambah catatan pertumbuhan baru ke Firestore
  Future<void> addRecord(GrowthRecordEntity record);

  /// Menghapus catatan pertumbuhan berdasarkan ID
  Future<void> deleteRecord(String childId, String recordId);

  /// Mengunggah foto catatan fisik ke Firebase Storage (maksimal 2MB)
  Future<String?> uploadPhoto({
    required String childId,
    required String fileName,
    required List<int> bytes,
    String contentType = 'image/jpeg',
  });
}
