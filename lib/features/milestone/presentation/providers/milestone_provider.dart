import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/kpsp_question_bank.dart';
import '../../domain/entities/milestone_entity.dart';

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

/// Hasil evaluasi terakhir (mock, nanti dari Firestore).
final lastMilestoneResultProvider =
    StateProvider<MilestoneResultEntity?>((ref) => null);
