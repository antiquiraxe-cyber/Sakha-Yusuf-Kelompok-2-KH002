import '../entities/milestone_entity.dart';

abstract class MilestoneRepository {
  /// Menyimpan hasil skrining KPSP ke Firestore
  Future<void> saveMilestoneResult(MilestoneResultEntity result);

  /// Mengambil seluruh riwayat skrining KPSP untuk seorang anak
  Future<List<MilestoneResultEntity>> getMilestoneHistory(String childId);

  /// Memantau riwayat skrining KPSP secara realtime
  Stream<List<MilestoneResultEntity>> watchMilestoneHistory(String childId);

  /// Mengambil hasil skrining KPSP paling terakhir untuk seorang anak
  Future<MilestoneResultEntity?> getLatestMilestoneResult(String childId);
}
