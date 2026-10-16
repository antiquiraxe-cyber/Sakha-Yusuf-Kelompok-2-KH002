import '../../../child_profile/domain/entities/child_entity.dart';

/// Tingkat bahaya/urgensi evaluasi fisik anak.
enum GrowthAlertLevel {
  normal, // Hijau: Pertumbuhan sesuai standar
  warning, // Kuning: Risiko stunting / gizi kurang / gizi lebih
  danger, // Merah: Terindikasi stunting parah / gizi buruk / obesitas
}

/// Klasifikasi status tinggi badan menurut usia (TB/U).
enum StuntingStatus {
  severelyStunted('Sangat Pendek (Severely Stunted)'),
  stunted('Pendek (Stunted)'),
  normal('Normal'),
  tall('Tinggi');

  final String label;
  const StuntingStatus(this.label);
}

/// Klasifikasi status berat badan menurut usia (BB/U).
enum WeightStatus {
  severelyUnderweight('Berat Badan Sangat Kurang (Gizi Buruk)'),
  underweight('Berat Badan Kurang (Gizi Kurang)'),
  normal('Berat Badan Normal'),
  overweightRisk('Risiko Berat Badan Lebih'),
  obese('Obesitas');

  final String label;
  const WeightStatus(this.label);
}

/// Hasil evaluasi antropometri fisik dan rekomendasi gizi anak.
class GrowthEvaluationResult {
  final StuntingStatus stuntingStatus;
  final WeightStatus weightStatus;
  final GrowthAlertLevel alertLevel;
  final double heightZScore;
  final double weightZScore;
  final double bmi;
  final String title;
  final String summary;
  final List<String> foodRecommendations;
  final List<String> foodsToAvoid;
  final String clinicalAction;

  const GrowthEvaluationResult({
    required this.stuntingStatus,
    required this.weightStatus,
    required this.alertLevel,
    required this.heightZScore,
    required this.weightZScore,
    required this.bmi,
    required this.title,
    required this.summary,
    required this.foodRecommendations,
    required this.foodsToAvoid,
    required this.clinicalAction,
  });

  bool get hasAlert => alertLevel != GrowthAlertLevel.normal;
}

class _RefPoint {
  final int month;
  final double hMed;
  final double hSd;
  final double wMed;
  final double wSd;
  const _RefPoint(this.month, this.hMed, this.hSd, this.wMed, this.wSd);
}

/// Layanan evaluasi pertumbuhan fisik anak berbasis standar Antropometri WHO & Kemenkes RI.
/// ponytail: Age-bracketed Kemenkes recommendations (0-5m ASI, 6-11m MPASI saring, 12-23m 1th lembek, 24-59m keluarga).
class GrowthEvaluationService {
  GrowthEvaluationService._();

  static const List<_RefPoint> _boysTable = [
    _RefPoint(0, 49.9, 1.89, 3.3, 0.45),
    _RefPoint(1, 54.7, 1.96, 4.5, 0.55),
    _RefPoint(2, 58.4, 2.04, 5.6, 0.65),
    _RefPoint(3, 61.4, 2.12, 6.4, 0.72),
    _RefPoint(4, 63.9, 2.19, 7.0, 0.78),
    _RefPoint(5, 65.9, 2.25, 7.5, 0.83),
    _RefPoint(6, 67.6, 2.30, 7.9, 0.88),
    _RefPoint(7, 69.2, 2.35, 8.3, 0.92),
    _RefPoint(8, 70.6, 2.39, 8.6, 0.96),
    _RefPoint(9, 72.0, 2.43, 8.9, 0.99),
    _RefPoint(10, 73.3, 2.47, 9.2, 1.02),
    _RefPoint(11, 74.5, 2.51, 9.4, 1.05),
    _RefPoint(12, 75.7, 2.54, 9.6, 1.08),
    _RefPoint(15, 79.1, 2.65, 10.3, 1.15),
    _RefPoint(18, 82.3, 2.77, 10.9, 1.23),
    _RefPoint(21, 85.1, 2.90, 11.5, 1.30),
    _RefPoint(24, 87.8, 3.04, 12.2, 1.38),
    _RefPoint(30, 91.9, 3.40, 13.3, 1.55),
    _RefPoint(36, 96.1, 3.80, 14.3, 1.70),
    _RefPoint(42, 99.9, 4.00, 15.3, 1.85),
    _RefPoint(48, 103.3, 4.25, 16.3, 2.05),
    _RefPoint(54, 106.7, 4.50, 17.3, 2.25),
    _RefPoint(60, 110.0, 4.75, 18.3, 2.45),
  ];

  static const List<_RefPoint> _girlsTable = [
    _RefPoint(0, 49.1, 1.86, 3.2, 0.43),
    _RefPoint(1, 53.7, 1.94, 4.2, 0.52),
    _RefPoint(2, 57.1, 2.02, 5.1, 0.61),
    _RefPoint(3, 59.8, 2.10, 5.8, 0.68),
    _RefPoint(4, 62.1, 2.17, 6.4, 0.74),
    _RefPoint(5, 64.0, 2.23, 6.9, 0.79),
    _RefPoint(6, 65.7, 2.29, 7.3, 0.84),
    _RefPoint(7, 67.3, 2.34, 7.6, 0.88),
    _RefPoint(8, 68.7, 2.39, 7.9, 0.92),
    _RefPoint(9, 70.1, 2.44, 8.2, 0.96),
    _RefPoint(10, 71.5, 2.49, 8.5, 0.99),
    _RefPoint(11, 72.8, 2.54, 8.7, 1.02),
    _RefPoint(12, 74.0, 2.58, 8.9, 1.05),
    _RefPoint(15, 77.5, 2.70, 9.6, 1.12),
    _RefPoint(18, 80.7, 2.82, 10.2, 1.20),
    _RefPoint(21, 83.7, 2.96, 10.9, 1.28),
    _RefPoint(24, 86.4, 3.10, 11.5, 1.36),
    _RefPoint(30, 90.7, 3.48, 12.7, 1.54),
    _RefPoint(36, 95.1, 3.88, 13.9, 1.72),
    _RefPoint(42, 99.0, 4.10, 15.0, 1.88),
    _RefPoint(48, 102.7, 4.35, 16.1, 2.08),
    _RefPoint(54, 106.2, 4.60, 17.2, 2.30),
    _RefPoint(60, 109.4, 4.85, 18.2, 2.50),
  ];

  static _RefPoint _interpolate(List<_RefPoint> table, int month) {
    final clamped = month.clamp(0, 60);
    if (clamped <= table.first.month) return table.first;
    if (clamped >= table.last.month) return table.last;

    for (int i = 0; i < table.length - 1; i++) {
      final p1 = table[i];
      final p2 = table[i + 1];
      if (clamped >= p1.month && clamped <= p2.month) {
        final t = (clamped - p1.month) / (p2.month - p1.month);
        return _RefPoint(
          clamped,
          p1.hMed + t * (p2.hMed - p1.hMed),
          p1.hSd + t * (p2.hSd - p1.hSd),
          p1.wMed + t * (p2.wMed - p1.wMed),
          p1.wSd + t * (p2.wSd - p1.wSd),
        );
      }
    }
    return table.last;
  }

  /// Mengevaluasi status pertumbuhan dan saran nutrisi spesifik usia anak.
  static GrowthEvaluationResult evaluate({
    required int ageInMonths,
    required Gender gender,
    required double weightKg,
    required double heightCm,
  }) {
    final table = (gender == Gender.female) ? _girlsTable : _boysTable;
    final ref = _interpolate(table, ageInMonths);

    final heightZScore = (heightCm - ref.hMed) / ref.hSd;
    final weightZScore = (weightKg - ref.wMed) / ref.wSd;

    final heightM = heightCm / 100.0;
    final bmi = (heightM > 0) ? (weightKg / (heightM * heightM)) : 0.0;

    // Klasifikasi TB/U (Stunting)
    final StuntingStatus stuntingStatus;
    if (heightZScore < -3.0) {
      stuntingStatus = StuntingStatus.severelyStunted;
    } else if (heightZScore < -2.0) {
      stuntingStatus = StuntingStatus.stunted;
    } else if (heightZScore > 3.0) {
      stuntingStatus = StuntingStatus.tall;
    } else {
      stuntingStatus = StuntingStatus.normal;
    }

    // Klasifikasi BB/U & Obesitas
    final WeightStatus weightStatus;
    if (weightZScore < -3.0) {
      weightStatus = WeightStatus.severelyUnderweight;
    } else if (weightZScore < -2.0) {
      weightStatus = WeightStatus.underweight;
    } else if (weightZScore > 3.0) {
      weightStatus = WeightStatus.obese;
    } else if (weightZScore > 2.0) {
      weightStatus = WeightStatus.overweightRisk;
    } else {
      weightStatus = WeightStatus.normal;
    }

    // Tentukan Level Alert
    final GrowthAlertLevel alertLevel;
    if (stuntingStatus == StuntingStatus.severelyStunted ||
        weightStatus == WeightStatus.severelyUnderweight ||
        weightStatus == WeightStatus.obese) {
      alertLevel = GrowthAlertLevel.danger;
    } else if (stuntingStatus == StuntingStatus.stunted ||
        weightStatus == WeightStatus.underweight ||
        weightStatus == WeightStatus.overweightRisk) {
      alertLevel = GrowthAlertLevel.warning;
    } else {
      alertLevel = GrowthAlertLevel.normal;
    }

    // Rekomendasi Gizi Sesuai Usia Klinis (0-5m, 6-11m, 12-23m, 24-59m)
    final advice = _getAdviceByAgeGroup(
      ageInMonths: ageInMonths,
      heightCm: heightCm,
      weightKg: weightKg,
      stuntingStatus: stuntingStatus,
      weightStatus: weightStatus,
      alertLevel: alertLevel,
    );

    return GrowthEvaluationResult(
      stuntingStatus: stuntingStatus,
      weightStatus: weightStatus,
      alertLevel: alertLevel,
      heightZScore: heightZScore,
      weightZScore: weightZScore,
      bmi: bmi,
      title: advice.title,
      summary: advice.summary,
      foodRecommendations: advice.foodRecs,
      foodsToAvoid: advice.foodsAvoid,
      clinicalAction: advice.clinicalAction,
    );
  }

  static ({
    String title,
    String summary,
    List<String> foodRecs,
    List<String> foodsAvoid,
    String clinicalAction,
  }) _getAdviceByAgeGroup({
    required int ageInMonths,
    required double heightCm,
    required double weightKg,
    required StuntingStatus stuntingStatus,
    required WeightStatus weightStatus,
    required GrowthAlertLevel alertLevel,
  }) {
    final isStuntingOrUnderweight =
        stuntingStatus == StuntingStatus.severelyStunted ||
        stuntingStatus == StuntingStatus.stunted ||
        weightStatus == WeightStatus.severelyUnderweight ||
        weightStatus == WeightStatus.underweight;

    final isObeseOrOverweight =
        weightStatus == WeightStatus.obese ||
        weightStatus == WeightStatus.overweightRisk;

    if (isStuntingOrUnderweight) {
      if (ageInMonths < 6) {
        return (
          title: alertLevel == GrowthAlertLevel.danger
              ? 'Peringatan: Kenaikan Berat/Panjang Bayi Usia 0–5 Bulan Kurang'
              : 'Perhatian: Pemantauan ASI Bayi Usia 0–5 Bulan',
          summary:
              'Panjang badan (${heightCm.toStringAsFixed(1)} cm) atau berat badan (${weightKg.toStringAsFixed(1)} kg) '
              'berada di bawah kurva standar bayi usia $ageInMonths bulan (${stuntingStatus.label}, ${weightStatus.label}).',
          foodRecs: [
            'Optimalkan ASI Eksklusif On-Demand: Susui bayi sesering mungkin (minimal 8–12 kali sehari, setiap 1.5–2 jam).',
            'Pastikan pelekatan menyusui (latch-on) tepat agar bayi mendapat hindmilk (ASI akhir yang kaya lemak & kalori).',
            'Ibu menyusui wajib meningkatkan asupan protein hewani (telur, ikan, daging) dan cairan minum minimal 3 liter per hari.',
            'Peringatan Kemenkes RI: Dilarang memberikan air putih, teh, madu, atau makanan padat sebelum bayi genap berusia 6 bulan.',
          ],
          foodsAvoid: [
            'Jangan berikan makanan padat, air putih, atau pisang lumat pada bayi di bawah 6 bulan.',
            'Hindari pemberian susu formula tanpa indikasi/resep dokter spesialis anak.',
          ],
          clinicalAction:
              'Segera periksakan bayi ke Puskesmas/Dokter Anak untuk evaluasi reflek hisap, posisi menyusui, dan penambahan berat badan harian.',
        );
      } else if (ageInMonths < 12) {
        return (
          title: alertLevel == GrowthAlertLevel.danger
              ? 'Peringatan: Indikasi Stunting/Gizi Kurang MPASI Awal (6–11 Bulan)'
              : 'Perhatian: Evaluasi MPASI Awal (6–11 Bulan)',
          summary:
              'Panjang/tinggi badan (${heightCm.toStringAsFixed(1)} cm) atau berat badan (${weightKg.toStringAsFixed(1)} kg) '
              'bayi usia $ageInMonths bulan di bawah standar normal (${stuntingStatus.label}, ${weightStatus.label}).',
          foodRecs: [
            'Protein Hewani Lumat Setiap Makan: Berikan hati ayam blender, kuning telur rebus lumat, atau ikan kembung cincang halus.',
            'Tambah Lemak Sehat: Campurkan 1 sdt minyak kelapa, santan matang, atau mentega tawar (unsalted butter) ke dalam mangkuk bubur MPASI.',
            'Tekstur MPASI Pas: Bubur kental lumat saring (6-8 bln), naik bertahap ke cincang halus (9-11 bln).',
            'Porsi & Frekuensi: 2–3 kali makan utama (2 sdm hingga 1/2 mangkuk 250ml) + 1–2 kali selingan (puree alpukat/pisang).',
            'Lanjutkan pemberian ASI sesuka bayi di luar jam makan MPASI.',
          ],
          foodsAvoid: [
            'Hindari memberi air putih berlebih atau jus buah sebelum makan agar lambung tidak cepat penuh.',
            'Stop biskuit bayi instan tinggi gula tambahan dan krimer kental manis.',
          ],
          clinicalAction:
              'Kunjungi Posyandu/Puskesmas untuk plotting kurva KMS dan mendapatkan PMT (Pemberian Makanan Tambahan) balita.',
        );
      } else if (ageInMonths < 24) {
        return (
          title: alertLevel == GrowthAlertLevel.danger
              ? 'Peringatan: Indikasi Stunting & Gizi Buruk Anak Usia 1–2 Tahun'
              : 'Perhatian: Waspada Stunting Anak Usia 1–2 Tahun',
          summary:
              'Tinggi badan (${heightCm.toStringAsFixed(1)} cm) atau berat badan (${weightKg.toStringAsFixed(1)} kg) '
              'anak usia $ageInMonths bulan (1 tahun) di bawah standar (${stuntingStatus.label}, ${weightStatus.label}).',
          foodRecs: [
            'Wajib Minimal 1 Butir Telur Ayam per Hari: Protein hewani paling utuh dan terbukti efektif mengatasi stunting.',
            'Lauk Hewani Cincang Lembut: Nasi tim/lembek dengan hati ayam, pepes ikan lele/kembung tanpa duri, atau bakso daging sapi.',
            'Camilan Padat Kalori: Puding santan telur, perkedel kentang isi daging giling, atau roti kukus selai kacang.',
            'Aturan Makan Disiplin (Feeding Rules): 3 kali makan utama + 2 kali selingan, waktu makan maksimal 30 menit.',
            'Batasi Susu Berlebih: Maksimal 400-500 ml/hari agar anak tidak kenyang susu dan tetap mau makan nasi & lauk.',
          ],
          foodsAvoid: [
            'Hindari memberi camilan manis, permen, wafer, atau kerupuk menjelang jam makan nasi.',
            'Stop pemberian teh manis dan minuman saset berpemanis.',
          ],
          clinicalAction:
              'Segera periksakan ke Dokter Anak/Puskesmas untuk skrining infeksi tersembunyi (seperti ISK atau anemia gizi besi) dan terapi pemulihan.',
        );
      } else {
        return (
          title: alertLevel == GrowthAlertLevel.danger
              ? 'Peringatan: Terindikasi Stunting Balita Usia 2–5 Tahun'
              : 'Perhatian: Waspada Stunting Balita Usia 2–5 Tahun',
          summary:
              'Tinggi badan (${heightCm.toStringAsFixed(1)} cm) atau berat badan (${weightKg.toStringAsFixed(1)} kg) '
              'anak usia $ageInMonths bulan di bawah standar kurva WHO (${stuntingStatus.label}, ${weightStatus.label}).',
          foodRecs: [
            'Menu Makanan Keluarga Kaya Protein: Nasi dengan ayam ungkep/goreng, sup iga sapi empuk, ikan kembung bakar, dan tempe/tahu bacem.',
            'Dua Lauk Hewani Berbeda: Berikan kombinasi 2 protein hewani berbeda sehari (contoh: telur pagi, ikan/daging siang & malam).',
            'Siasati Porsi Kalori: Tambahkan kuah santan, keju parut, atau minyak gurih pada masakan untuk meningkatkan kalori.',
            'Camilan Sehat: Buah segar (alpukat, pepaya, pisang) dan susu pertumbuhan sebagai pelengkap makan nasi.',
          ],
          foodsAvoid: [
            'Stop total jajanan ultra-proses (ciki), mi instan, gorengan bertepung tebal, dan minuman dingin kemasan.',
          ],
          clinicalAction:
              'Segera konsultasikan ke fasilitas kesehatan untuk penanganan tatalaksana gizi buruk/stunting dari tim medis Puskesmas.',
        );
      }
    } else if (isObeseOrOverweight) {
      if (ageInMonths < 6) {
        return (
          title: 'Evaluasi Kenaikan Berat Badan Bayi Usia 0–5 Bulan',
          summary:
              'Berat badan (${weightKg.toStringAsFixed(1)} kg) berada di atas kurva rata-rata bayi usia $ageInMonths bulan (${weightStatus.label}).',
          foodRecs: [
            'Pertahankan pemberian ASI Eksklusif sesuai kebutuhan bayi.',
            'Jika mengonsumsi susu formula, pastikan takaran sendok dan air sesuai petunjuk kemasan (jangan terlalu pekat).',
          ],
          foodsAvoid: [
            'Dilarang memberi air gula, madu, atau makanan padat sebelum usia 6 bulan.',
          ],
          clinicalAction:
              'Konsultasikan ke dokter anak saat imunisasi rutin untuk memastikan pertumbuhan berat seimbang dengan panjang badannya.',
        );
      } else if (ageInMonths < 12) {
        return (
          title: 'Rekomendasi MPASI Pengendalian Berat Badan (6–11 Bulan)',
          summary:
              'Berat badan (${weightKg.toStringAsFixed(1)} kg) melampaui kurva normal usia $ageInMonths bulan (${weightStatus.label}).',
          foodRecs: [
            'Gunakan bahan MPASI alami tanpa tambahan gula, garam berlebih, atau pemanis buatan.',
            'Perbanyak porsi sayuran kukus lumat (labu siam, brokoli, wortel) dan protein rendah lemak (dada ayam, tahu, ikan).',
            'Pertahankan pemberian ASI sebagai sumber nutrisi cairan utama.',
          ],
          foodsAvoid: [
            'Stop pemberian biskuit bayi manis, puree buah kemasan bersirup, dan kental manis.',
          ],
          clinicalAction:
              'Konsultasi ke posyandu untuk plotting kurva BB/TB agar kenaikan berat seirama dengan tinggi badannya.',
        );
      } else if (ageInMonths < 24) {
        return (
          title: 'Rekomendasi Pengendalian Berat Badan Anak 1–2 Tahun',
          summary:
              'Berat badan (${weightKg.toStringAsFixed(1)} kg) melampaui kurva rata-rata anak usia $ageInMonths bulan (${weightStatus.label}).',
          foodRecs: [
            'Porsi Makan Seimbang: Utamakan sayur bening, buah potong segar, dan protein tanpa lemak (telur rebus, dada ayam suwir).',
            'Air Putih Utama: Biasakan anak minum air putih saat haus, bukan minuman manis atau susu berlebihan.',
            'Batasi Konsumsi Susu: Maksimal 400 ml per hari agar kalori cair tidak berlebihan.',
            'Aktivitas Fisik: Ajak anak aktif berjalan dan bermain di luar ruangan minimal 60 menit per hari.',
          ],
          foodsAvoid: [
            'Hentikan minuman manis kemasan, jus kotak berpemanis, dan biskuit cokelat/wafer.',
            'Kurangi makanan cepat saji, sosis siap makan, dan nugget bertepung tebal.',
          ],
          clinicalAction:
              'Konsultasikan dengan ahli gizi di Puskesmas untuk evaluasi menu harian balita.',
        );
      } else {
        return (
          title: 'Panduan Gizi Pengendalian Obesitas Balita 2–5 Tahun',
          summary:
              'Berat badan (${weightKg.toStringAsFixed(1)} kg) melampaui batas kurva normal balita usia $ageInMonths bulan (${weightStatus.label}).',
          foodRecs: [
            'Prinsip "Isi Piringku Balita": 1/3 karbohidrat (nasi/ubi), 1/3 sayur & buah segar, 1/3 lauk protein rendah lemak.',
            'Pilih Metode Masak Sehat: Kukus, rebus, tim, atau panggang daripada gorengan minyak tebal.',
            'Camilan Tunggal Buah Segar: Berikan buah potong segar (bukan jus dengan gula) sebagai camilan di antara jam makan.',
            'Aktivitas Gerak Aktif: Ajak anak lari, sepeda, atau lompat minimal 60 menit sehari dan batasi screen time (TV/HP) < 1 jam.',
          ],
          foodsAvoid: [
            'Stop total minuman bersoda, boba, sirup, teh manis kemasan, dan fast food.',
            'Jangan gunakan makanan manis/junk food sebagai hadiah (reward) anak.',
          ],
          clinicalAction:
              'Pemeriksaan medis di Puskesmas/Dokter Anak untuk panduan gizi aman tanpa mengganggu pertambahan tinggi badan anak.',
        );
      }
    } else {
      if (ageInMonths < 6) {
        return (
          title: 'Pertumbuhan Bayi Normal (Usia 0–5 Bulan)',
          summary:
              'Panjang (${heightCm.toStringAsFixed(1)} cm) dan berat badan (${weightKg.toStringAsFixed(1)} kg) bayi berada di rentang normal WHO.',
          foodRecs: [
            'Lanjutkan ASI Eksklusif secara on-demand (sesuai keinginan bayi).',
            'Jaga kesehatan dan kecukupan gizi ibu menyusui.',
          ],
          foodsAvoid: [
            'Jangan berikan makanan/cairan selain ASI sebelum genap 6 bulan.',
          ],
          clinicalAction:
              'Lanjutkan penimbangan rutin dan imunisasi bulanan di Posyandu.',
        );
      } else if (ageInMonths < 12) {
        return (
          title: 'Pertumbuhan MPASI Bayi Normal (6–11 Bulan)',
          summary:
              'Panjang/tinggi (${heightCm.toStringAsFixed(1)} cm) dan berat (${weightKg.toStringAsFixed(1)} kg) berada di rentang normal WHO.',
          foodRecs: [
            'Berikan MPASI bergizi seimbang lengkap (karbohidrat, protein hewani, lemak sehat, sayur/buah).',
            'Tingkatkan tekstur MPASI bertahap sesuai usia bayi.',
          ],
          foodsAvoid: [
            'Batasi jajanan kemasan dan makanan berpemanis buatan.',
          ],
          clinicalAction:
              'Pantau penimbangan berat badan dan tinggi badan rutin di Posyandu.',
        );
      } else if (ageInMonths < 24) {
        return (
          title: 'Pertumbuhan Anak Normal (1–2 Tahun)',
          summary:
              'Tinggi (${heightCm.toStringAsFixed(1)} cm) dan berat (${weightKg.toStringAsFixed(1)} kg) anak berada di rentang normal WHO.',
          foodRecs: [
            'Berikan 1 butir telur ayam setiap hari dan variasikan lauk hewani lainnya.',
            'Terapkan jadwal makan teratur (3x makan utama, 2x selingan).',
          ],
          foodsAvoid: [
            'Batasi jajanan manis dan makanan cepat saji.',
          ],
          clinicalAction:
              'Lanjutkan penimbangan bulanan dan stimulasi tumbuh kembang.',
        );
      } else {
        return (
          title: 'Pertumbuhan Balita Normal (2–5 Tahun)',
          summary:
              'Tinggi (${heightCm.toStringAsFixed(1)} cm) dan berat (${weightKg.toStringAsFixed(1)} kg) anak berada di rentang normal WHO.',
          foodRecs: [
            'Pertahankan prinsip gizi seimbang "Isi Piringku Balita".',
            'Sediakan buah segar dan air putih yang cukup harian.',
          ],
          foodsAvoid: [
            'Batasi makanan ultra-proses, makanan gorengan tebal, dan minuman tinggi gula.',
          ],
          clinicalAction:
              'Lanjutkan pemantauan tumbuh kembang bulanan di Posyandu/Puskesmas.',
        );
      }
    }
  }
}
