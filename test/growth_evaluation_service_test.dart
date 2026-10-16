import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/tracking/domain/services/growth_evaluation_service.dart';

void main() {
  group('GrowthEvaluationService Test (Standar WHO / Kemenkes Berbasis Usia)', () {
    test('Kasus 0-5 Bulan: Bayi 3 bulan BB/TB kurang fokus optimasi ASI Eksklusif', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 3,
        gender: Gender.male,
        heightCm: 53.0, // di bawah normal
        weightKg: 4.2, // di bawah normal
      );

      expect(result.alertLevel, GrowthAlertLevel.danger);
      expect(result.foodRecommendations.any((r) => r.contains('ASI Eksklusif')), isTrue);
      expect(result.foodRecommendations.any((r) => r.contains('Kemenkes RI')), isTrue);
      expect(result.foodsToAvoid.any((f) => f.contains('makanan padat')), isTrue);
    });

    test('Kasus 6-11 Bulan: Bayi 9 bulan stunting fokus MPASI lumat & lemak sehat', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 9,
        gender: Gender.female,
        heightCm: 63.0,
        weightKg: 6.0,
      );

      expect(result.alertLevel, GrowthAlertLevel.warning);
      expect(result.foodRecommendations.any((r) => r.contains('Protein Hewani Lumat')), isTrue);
      expect(result.foodRecommendations.any((r) => r.contains('minyak kelapa') || r.contains('santan')), isTrue);
      expect(result.clinicalAction, contains('Posyandu/Puskesmas'));
    });

    test('Kasus Dosen (12-23 Bulan / 1 Tahun): Anak Yusuf 12 bulan, TB 50cm, BB 5kg stunting berat', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 12, // 1 tahun
        gender: Gender.male,
        heightCm: 50.0,
        weightKg: 5.0,
      );

      // Verifikasi alert merah bahaya & klasifikasi
      expect(result.alertLevel, GrowthAlertLevel.danger);
      expect(result.hasAlert, isTrue);
      expect(result.stuntingStatus, StuntingStatus.severelyStunted);
      expect(result.weightStatus, WeightStatus.severelyUnderweight);

      // Verifikasi rekomendasi usia 1 tahun: telur ayam utuh harian & lauk cincang lembut
      expect(result.foodRecommendations.any((r) => r.toLowerCase().contains('protein hewani')), isTrue);
      expect(result.foodRecommendations.any((r) => r.contains('1 Butir Telur')), isTrue);
      expect(result.foodRecommendations.any((r) => r.contains('Feeding Rules')), isTrue);
      expect(result.clinicalAction, contains('Puskesmas'));
    });

    test('Kasus 2-5 Tahun (24-59 Bulan): Anak 36 bulan stunting menu keluarga kaya protein', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 36,
        gender: Gender.male,
        heightCm: 84.0, // Severely stunted untuk 36 bulan
        weightKg: 10.0,
      );

      expect(result.alertLevel, GrowthAlertLevel.danger);
      expect(result.foodRecommendations.any((r) => r.contains('Makanan Keluarga Kaya Protein')), isTrue);
      expect(result.foodsToAvoid.any((f) => f.contains('ultra-proses')), isTrue);
    });

    test('Kasus Anak Obesitas: 24 bulan BB 18kg TB 88cm memicu alert obesitas dan batasi gula', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 24,
        gender: Gender.male,
        heightCm: 88.0,
        weightKg: 18.0,
      );

      expect(result.alertLevel, GrowthAlertLevel.danger);
      expect(result.weightStatus, WeightStatus.obese);
      expect(result.stuntingStatus, StuntingStatus.normal);

      // Verifikasi saran gizi obesitas balita
      expect(result.foodsToAvoid.any((f) => f.contains('minuman bersoda') || f.contains('sirup') || f.contains('manis')), isTrue);
      expect(result.foodRecommendations.any((f) => f.contains('Isi Piringku Balita')), isTrue);
    });

    test('Kasus Anak Normal: 12 bulan BB 9.6kg TB 76cm berada di rentang normal', () {
      final result = GrowthEvaluationService.evaluate(
        ageInMonths: 12,
        gender: Gender.male,
        heightCm: 76.0,
        weightKg: 9.6,
      );

      expect(result.alertLevel, GrowthAlertLevel.normal);
      expect(result.hasAlert, isFalse);
      expect(result.stuntingStatus, StuntingStatus.normal);
      expect(result.weightStatus, WeightStatus.normal);
      expect(result.title, contains('Normal'));
    });
  });
}
