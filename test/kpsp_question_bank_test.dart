import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/milestone/data/kpsp_question_bank.dart';
import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';

void main() {
  group('KpspQuestionBank', () {
    test('setiap usia memiliki 9-10 soal sesuai formulir KPSP', () {
      for (final age in KpspQuestionBank.availableAges) {
        final questions = KpspQuestionBank.getQuestions(age);
        expect(questions.length >= 9 && questions.length <= 10, isTrue,
            reason: 'usia $age bulan harus punya 9-10 soal');
      }
    });

    test('setiap soal memiliki id unik', () {
      final allQuestions = KpspQuestionBank.availableAges
          .expand((age) => KpspQuestionBank.getQuestions(age))
          .toList();
      final ids = allQuestions.map((q) => q.id).toList();
      final uniqueIds = ids.toSet();

      expect(uniqueIds.length, ids.length);
    });

    test('getNearestAge mengembalikan usia KPSP terdekat ke bawah', () {
      expect(KpspQuestionBank.getNearestAge(2), isNull);
      expect(KpspQuestionBank.getNearestAge(3), 3);
      expect(KpspQuestionBank.getNearestAge(4), 3);
      expect(KpspQuestionBank.getNearestAge(5), 3);
      expect(KpspQuestionBank.getNearestAge(11), 9);
      expect(KpspQuestionBank.getNearestAge(12), 12);
      expect(KpspQuestionBank.getNearestAge(25), 24);
      expect(KpspQuestionBank.getNearestAge(60), 60);
    });

    test('setiap soal memiliki aspek dan teks yang valid', () {
      for (final age in KpspQuestionBank.availableAges) {
        final questions = KpspQuestionBank.getQuestions(age);
        for (final q in questions) {
          expect(q.question.isNotEmpty, isTrue);
          expect(q.ageMonth, age);
        }
      }
    });

    test('calculateStatus proporsional terhadap jumlah soal', () {
      // 10 soal: 9 Ya = sesuai, 7 = meragukan, 6 = penyimpangan
      expect(MilestoneResultEntity.calculateStatus(9, 10),
          MilestoneStatus.sesuai);
      expect(MilestoneResultEntity.calculateStatus(7, 10),
          MilestoneStatus.meragukan);
      expect(MilestoneResultEntity.calculateStatus(6, 10),
          MilestoneStatus.penyimpangan);
      // 9 soal: 9 Ya (100%) = sesuai, 8 Ya (89%) = meragukan
      expect(MilestoneResultEntity.calculateStatus(9, 9),
          MilestoneStatus.sesuai);
      expect(MilestoneResultEntity.calculateStatus(8, 9),
          MilestoneStatus.meragukan);
    });
  });
}
