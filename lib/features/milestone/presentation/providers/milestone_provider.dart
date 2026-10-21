import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/kpsp_question_bank.dart';
import '../../data/repositories/milestone_repository_impl.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';

/// Provider untuk instance MilestoneRepository
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepositoryImpl();
});

/// Provider untuk daftar soal KPSP berdasarkan usia evaluasi.
final kpspQuestionsProvider =
    Provider.family<List<MilestoneQuestionEntity>, int>((ref, ageMonth) {
  return KpspQuestionBank.getQuestions(ageMonth);
});

/// State jawaban: questionId -> true (Ya) / false (Tidak).
/// null = belum dijawab.
class MilestoneAnswersNotifier
    extends StateNotifier<Map<String, bool?>> {
  MilestoneAnswersNotifier() : super({});

  void setAnswer(String questionId, bool answer) {
    state = {...state, questionId: answer};
  }

  void reset() {
    state = {};
  }

  bool get isComplete => state.values.every((v) => v != null);

  int get totalYes => state.values.where((v) => v == true).length;

  int get answeredCount => state.values.where((v) => v != null).length;
}

/// Provider jawaban milestone.
final milestoneAnswersProvider =
    StateNotifierProvider<MilestoneAnswersNotifier, Map<String, bool?>>(
  (ref) => MilestoneAnswersNotifier(),
);

/// Hasil evaluasi terakhir sementara di memori
final lastMilestoneResultProvider =
    StateProvider<MilestoneResultEntity?>((ref) => null);

/// Stream riwayat evaluasi milestone anak dari Firestore
final milestoneHistoryStreamProvider =
    StreamProvider.family<List<MilestoneResultEntity>, String>((ref, childId) {
  final repo = ref.watch(milestoneRepositoryProvider);
  return repo.watchMilestoneHistory(childId);
});

/// Provider hasil evaluasi milestone paling baru untuk seorang anak
final latestMilestoneResultProvider =
    Provider.family<MilestoneResultEntity?, String>((ref, childId) {
  final historyAsync = ref.watch(milestoneHistoryStreamProvider(childId));
  return historyAsync.maybeWhen(
    data: (records) => records.isEmpty ? null : records.first,
    orElse: () => null,
  );
});
