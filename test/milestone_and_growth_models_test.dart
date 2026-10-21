import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/milestone/data/models/milestone_model.dart';
import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';
import 'package:langkahawal/features/tracking/data/models/growth_record_model.dart';

void main() {
  group('MilestoneResultModel Unit Test', () {
    test('toJson dan fromJson mengonversi field MilestoneResult dengan benar', () {
      final now = DateTime(2026, 10, 21, 10, 0);
      final model = MilestoneResultModel(
        id: 'ms_01',
        childId: 'ch_01',
        ageMonthEvaluated: 12,
        answers: const {'q1': true, 'q2': false, 'q3': true},
        totalYes: 2,
        status: MilestoneStatus.meragukan,
        evaluatedAt: now,
      );

      final json = model.toJson();
      expect(json['id'], 'ms_01');
      expect(json['childId'], 'ch_01');
      expect(json['totalYes'], 2);
      expect(json['status'], 'meragukan');

      final reconstructed = MilestoneResultModel.fromJson(json);
      expect(reconstructed.id, model.id);
      expect(reconstructed.status, MilestoneStatus.meragukan);
      expect(reconstructed.answers['q1'], true);
      expect(reconstructed.answers['q2'], false);
    });

    test('toFirestore menghasilkan field dan status name yang sesuai', () {
      final now = DateTime(2026, 10, 21);
      final model = MilestoneResultModel(
        id: 'ms_02',
        childId: 'ch_02',
        ageMonthEvaluated: 24,
        answers: const {'q1': true},
        totalYes: 1,
        status: MilestoneStatus.sesuai,
        evaluatedAt: now,
      );

      final firestoreMap = model.toFirestore();
      expect(firestoreMap['childId'], 'ch_02');
      expect(firestoreMap['status'], 'sesuai');
      expect(firestoreMap['totalYes'], 1);
    });
  });

  group('GrowthRecordModel Unit Test', () {
    test('toJson dan fromJson mengonversi field GrowthRecord dengan benar', () {
      final recordDate = DateTime(2026, 10, 20);
      final createdAt = DateTime(2026, 10, 20, 15, 30);
      final model = GrowthRecordModel(
        id: 'gr_01',
        childId: 'ch_01',
        recordDate: recordDate,
        weightKg: 10.2,
        heightCm: 76.5,
        headCircumferenceCm: 45.0,
        note: 'Sehat dan ceria',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: createdAt,
      );

      final json = model.toJson();
      expect(json['weightKg'], 10.2);
      expect(json['heightCm'], 76.5);
      expect(json['headCircumferenceCm'], 45.0);
      expect(json['note'], 'Sehat dan ceria');

      final reconstructed = GrowthRecordModel.fromJson(json);
      expect(reconstructed.id, 'gr_01');
      expect(reconstructed.weightKg, 10.2);
      expect(reconstructed.heightCm, 76.5);
      expect(reconstructed.headCircumferenceCm, 45.0);
      expect(reconstructed.note, 'Sehat dan ceria');
    });

    test('toFirestore mengonversi GrowthRecordModel dengan benar', () {
      final now = DateTime(2026, 10, 21);
      final model = GrowthRecordModel(
        id: 'gr_02',
        childId: 'ch_02',
        recordDate: now,
        weightKg: 8.5,
        heightCm: 68.0,
        createdAt: now,
      );

      final firestoreMap = model.toFirestore();
      expect(firestoreMap['childId'], 'ch_02');
      expect(firestoreMap['weightKg'], 8.5);
      expect(firestoreMap['heightCm'], 68.0);
      expect(firestoreMap['headCircumferenceCm'], isNull);
    });
  });
}
