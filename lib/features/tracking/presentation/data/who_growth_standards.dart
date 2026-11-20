import 'package:fl_chart/fl_chart.dart';
import '../../../child_profile/domain/entities/child_entity.dart';
import '../screens/growth_chart_screen.dart';

/// Data kurva pertumbuhan standar WHO untuk anak 0-60 bulan.
/// Sumber: WHO Child Growth Standards (https://www.who.int/tools/child-growth-standards)
class WhoGrowthStandards {
  WhoGrowthStandards._();

  static WhoStandardData getStandards(GrowthChartTab tab, Gender gender) {
    switch (tab) {
      case GrowthChartTab.weight:
        return gender == Gender.male ? _weightMale : _weightFemale;
      case GrowthChartTab.height:
        return gender == Gender.male ? _heightMale : _heightFemale;
      case GrowthChartTab.headCircumference:
        return gender == Gender.male ? _headMale : _headFemale;
    }
  }

  // ========== BERAT BADAN LAKI-LAKI (kg) ==========
  static final WhoStandardData _weightMale = WhoStandardData(
    p3: [
      const FlSpot(0, 2.5), const FlSpot(1, 3.4), const FlSpot(2, 4.3),
      const FlSpot(3, 5.0), const FlSpot(4, 5.6), const FlSpot(5, 6.0),
      const FlSpot(6, 6.4), const FlSpot(7, 6.7), const FlSpot(8, 6.9),
      const FlSpot(9, 7.1), const FlSpot(10, 7.4), const FlSpot(11, 7.6),
      const FlSpot(12, 7.7), const FlSpot(15, 8.3), const FlSpot(18, 8.8),
      const FlSpot(21, 9.2), const FlSpot(24, 9.7), const FlSpot(30, 10.5),
      const FlSpot(36, 11.3), const FlSpot(42, 12.1), const FlSpot(48, 12.9),
      const FlSpot(54, 13.6), const FlSpot(60, 14.3),
    ],
    p50: [
      const FlSpot(0, 3.3), const FlSpot(1, 4.5), const FlSpot(2, 5.6),
      const FlSpot(3, 6.4), const FlSpot(4, 7.0), const FlSpot(5, 7.5),
      const FlSpot(6, 7.9), const FlSpot(7, 8.3), const FlSpot(8, 8.6),
      const FlSpot(9, 8.9), const FlSpot(10, 9.2), const FlSpot(11, 9.4),
      const FlSpot(12, 9.6), const FlSpot(15, 10.3), const FlSpot(18, 10.9),
      const FlSpot(21, 11.5), const FlSpot(24, 12.2), const FlSpot(30, 13.3),
      const FlSpot(36, 14.3), const FlSpot(42, 15.3), const FlSpot(48, 16.3),
      const FlSpot(54, 17.3), const FlSpot(60, 18.3),
    ],
    p97: [
      const FlSpot(0, 4.4), const FlSpot(1, 5.8), const FlSpot(2, 7.1),
      const FlSpot(3, 8.0), const FlSpot(4, 8.7), const FlSpot(5, 9.3),
      const FlSpot(6, 9.8), const FlSpot(7, 10.3), const FlSpot(8, 10.7),
      const FlSpot(9, 11.0), const FlSpot(10, 11.4), const FlSpot(11, 11.7),
      const FlSpot(12, 12.0), const FlSpot(15, 12.8), const FlSpot(18, 13.7),
      const FlSpot(21, 14.5), const FlSpot(24, 15.3), const FlSpot(30, 16.9),
      const FlSpot(36, 18.3), const FlSpot(42, 19.7), const FlSpot(48, 21.2),
      const FlSpot(54, 22.7), const FlSpot(60, 24.2),
    ],
  );

  // ========== BERAT BADAN PEREMPUAN (kg) ==========
  static final WhoStandardData _weightFemale = WhoStandardData(
    p3: [
      const FlSpot(0, 2.4), const FlSpot(1, 3.2), const FlSpot(2, 3.9),
      const FlSpot(3, 4.5), const FlSpot(4, 5.0), const FlSpot(5, 5.4),
      const FlSpot(6, 5.7), const FlSpot(7, 6.0), const FlSpot(8, 6.3),
      const FlSpot(9, 6.5), const FlSpot(10, 6.7), const FlSpot(11, 6.9),
      const FlSpot(12, 7.0), const FlSpot(15, 7.6), const FlSpot(18, 8.1),
      const FlSpot(21, 8.6), const FlSpot(24, 9.0), const FlSpot(30, 9.9),
      const FlSpot(36, 10.8), const FlSpot(42, 11.6), const FlSpot(48, 12.3),
      const FlSpot(54, 13.0), const FlSpot(60, 13.7),
    ],
    p50: [
      const FlSpot(0, 3.2), const FlSpot(1, 4.2), const FlSpot(2, 5.1),
      const FlSpot(3, 5.8), const FlSpot(4, 6.4), const FlSpot(5, 6.9),
      const FlSpot(6, 7.3), const FlSpot(7, 7.6), const FlSpot(8, 7.9),
      const FlSpot(9, 8.2), const FlSpot(10, 8.5), const FlSpot(11, 8.7),
      const FlSpot(12, 8.9), const FlSpot(15, 9.6), const FlSpot(18, 10.2),
      const FlSpot(21, 10.9), const FlSpot(24, 11.5), const FlSpot(30, 12.7),
      const FlSpot(36, 13.9), const FlSpot(42, 15.0), const FlSpot(48, 16.1),
      const FlSpot(54, 17.2), const FlSpot(60, 18.2),
    ],
    p97: [
      const FlSpot(0, 4.2), const FlSpot(1, 5.5), const FlSpot(2, 6.6),
      const FlSpot(3, 7.5), const FlSpot(4, 8.2), const FlSpot(5, 8.8),
      const FlSpot(6, 9.3), const FlSpot(7, 9.8), const FlSpot(8, 10.2),
      const FlSpot(9, 10.5), const FlSpot(10, 10.9), const FlSpot(11, 11.2),
      const FlSpot(12, 11.5), const FlSpot(15, 12.4), const FlSpot(18, 13.2),
      const FlSpot(21, 14.0), const FlSpot(24, 14.8), const FlSpot(30, 16.5),
      const FlSpot(36, 18.1), const FlSpot(42, 19.8), const FlSpot(48, 21.5),
      const FlSpot(54, 23.2), const FlSpot(60, 25.0),
    ],
  );

  // ========== TINGGI BADAN LAKI-LAKI (cm) ==========
  static final WhoStandardData _heightMale = WhoStandardData(
    p3: [
      const FlSpot(0, 46.1), const FlSpot(1, 51.1), const FlSpot(2, 54.4),
      const FlSpot(3, 57.3), const FlSpot(4, 59.7), const FlSpot(5, 61.7),
      const FlSpot(6, 63.3), const FlSpot(7, 64.8), const FlSpot(8, 66.2),
      const FlSpot(9, 67.5), const FlSpot(10, 68.7), const FlSpot(11, 69.9),
      const FlSpot(12, 71.0), const FlSpot(15, 74.1), const FlSpot(18, 76.9),
      const FlSpot(21, 79.4), const FlSpot(24, 81.7), const FlSpot(30, 85.7),
      const FlSpot(36, 89.4), const FlSpot(42, 92.9), const FlSpot(48, 96.1),
      const FlSpot(54, 99.3), const FlSpot(60, 102.3),
    ],
    p50: [
      const FlSpot(0, 49.9), const FlSpot(1, 54.7), const FlSpot(2, 58.4),
      const FlSpot(3, 61.4), const FlSpot(4, 63.9), const FlSpot(5, 65.9),
      const FlSpot(6, 67.6), const FlSpot(7, 69.2), const FlSpot(8, 70.6),
      const FlSpot(9, 72.0), const FlSpot(10, 73.3), const FlSpot(11, 74.5),
      const FlSpot(12, 75.7), const FlSpot(15, 79.1), const FlSpot(18, 82.3),
      const FlSpot(21, 85.1), const FlSpot(24, 87.8), const FlSpot(30, 92.4),
      const FlSpot(36, 96.5), const FlSpot(42, 100.3), const FlSpot(48, 103.9),
      const FlSpot(54, 107.4), const FlSpot(60, 110.6),
    ],
    p97: [
      const FlSpot(0, 53.7), const FlSpot(1, 58.6), const FlSpot(2, 62.4),
      const FlSpot(3, 65.5), const FlSpot(4, 68.0), const FlSpot(5, 70.1),
      const FlSpot(6, 71.9), const FlSpot(7, 73.5), const FlSpot(8, 75.0),
      const FlSpot(9, 76.5), const FlSpot(10, 77.9), const FlSpot(11, 79.2),
      const FlSpot(12, 80.5), const FlSpot(15, 84.2), const FlSpot(18, 87.7),
      const FlSpot(21, 90.9), const FlSpot(24, 93.9), const FlSpot(30, 99.1),
      const FlSpot(36, 103.6), const FlSpot(42, 107.8), const FlSpot(48, 111.7),
      const FlSpot(54, 115.5), const FlSpot(60, 119.0),
    ],
  );

  // ========== TINGGI BADAN PEREMPUAN (cm) ==========
  static final WhoStandardData _heightFemale = WhoStandardData(
    p3: [
      const FlSpot(0, 45.4), const FlSpot(1, 50.0), const FlSpot(2, 53.0),
      const FlSpot(3, 55.6), const FlSpot(4, 57.8), const FlSpot(5, 59.6),
      const FlSpot(6, 61.2), const FlSpot(7, 62.7), const FlSpot(8, 64.0),
      const FlSpot(9, 65.3), const FlSpot(10, 66.5), const FlSpot(11, 67.7),
      const FlSpot(12, 68.9), const FlSpot(15, 72.0), const FlSpot(18, 74.9),
      const FlSpot(21, 77.5), const FlSpot(24, 80.0), const FlSpot(30, 84.4),
      const FlSpot(36, 88.4), const FlSpot(42, 92.0), const FlSpot(48, 95.4),
      const FlSpot(54, 98.6), const FlSpot(60, 101.8),
    ],
    p50: [
      const FlSpot(0, 49.1), const FlSpot(1, 53.7), const FlSpot(2, 57.1),
      const FlSpot(3, 59.8), const FlSpot(4, 62.1), const FlSpot(5, 64.0),
      const FlSpot(6, 65.7), const FlSpot(7, 67.3), const FlSpot(8, 68.7),
      const FlSpot(9, 70.1), const FlSpot(10, 71.5), const FlSpot(11, 72.8),
      const FlSpot(12, 74.0), const FlSpot(15, 77.5), const FlSpot(18, 80.7),
      const FlSpot(21, 83.7), const FlSpot(24, 86.4), const FlSpot(30, 91.1),
      const FlSpot(36, 95.4), const FlSpot(42, 99.4), const FlSpot(48, 103.1),
      const FlSpot(54, 106.6), const FlSpot(60, 110.0),
    ],
    p97: [
      const FlSpot(0, 52.9), const FlSpot(1, 57.6), const FlSpot(2, 61.1),
      const FlSpot(3, 64.0), const FlSpot(4, 66.4), const FlSpot(5, 68.5),
      const FlSpot(6, 70.3), const FlSpot(7, 71.9), const FlSpot(8, 73.5),
      const FlSpot(9, 74.9), const FlSpot(10, 76.4), const FlSpot(11, 77.8),
      const FlSpot(12, 79.2), const FlSpot(15, 83.0), const FlSpot(18, 86.5),
      const FlSpot(21, 89.8), const FlSpot(24, 92.9), const FlSpot(30, 98.1),
      const FlSpot(36, 102.7), const FlSpot(42, 106.9), const FlSpot(48, 110.9),
      const FlSpot(54, 114.7), const FlSpot(60, 118.3),
    ],
  );

  // ========== LINGKAR KEPALA LAKI-LAKI (cm) ==========
  static final WhoStandardData _headMale = WhoStandardData(
    p3: [
      const FlSpot(0, 32.1), const FlSpot(1, 35.1), const FlSpot(2, 37.0),
      const FlSpot(3, 38.3), const FlSpot(4, 39.4), const FlSpot(5, 40.3),
      const FlSpot(6, 41.0), const FlSpot(7, 41.7), const FlSpot(8, 42.2),
      const FlSpot(9, 42.6), const FlSpot(10, 43.0), const FlSpot(11, 43.4),
      const FlSpot(12, 43.6), const FlSpot(15, 44.3), const FlSpot(18, 44.8),
      const FlSpot(21, 45.2), const FlSpot(24, 45.5), const FlSpot(30, 46.1),
      const FlSpot(36, 46.5), const FlSpot(42, 46.9), const FlSpot(48, 47.2),
      const FlSpot(54, 47.5), const FlSpot(60, 47.7),
    ],
    p50: [
      const FlSpot(0, 34.5), const FlSpot(1, 37.3), const FlSpot(2, 39.1),
      const FlSpot(3, 40.5), const FlSpot(4, 41.6), const FlSpot(5, 42.6),
      const FlSpot(6, 43.3), const FlSpot(7, 44.0), const FlSpot(8, 44.5),
      const FlSpot(9, 45.0), const FlSpot(10, 45.4), const FlSpot(11, 45.8),
      const FlSpot(12, 46.1), const FlSpot(15, 46.8), const FlSpot(18, 47.4),
      const FlSpot(21, 47.8), const FlSpot(24, 48.2), const FlSpot(30, 48.8),
      const FlSpot(36, 49.3), const FlSpot(42, 49.7), const FlSpot(48, 50.0),
      const FlSpot(54, 50.3), const FlSpot(60, 50.5),
    ],
    p97: [
      const FlSpot(0, 37.0), const FlSpot(1, 39.5), const FlSpot(2, 41.3),
      const FlSpot(3, 42.7), const FlSpot(4, 43.9), const FlSpot(5, 44.8),
      const FlSpot(6, 45.6), const FlSpot(7, 46.3), const FlSpot(8, 46.9),
      const FlSpot(9, 47.4), const FlSpot(10, 47.8), const FlSpot(11, 48.2),
      const FlSpot(12, 48.5), const FlSpot(15, 49.3), const FlSpot(18, 49.9),
      const FlSpot(21, 50.4), const FlSpot(24, 50.8), const FlSpot(30, 51.5),
      const FlSpot(36, 52.0), const FlSpot(42, 52.5), const FlSpot(48, 52.9),
      const FlSpot(54, 53.2), const FlSpot(60, 53.4),
    ],
  );

  // ========== LINGKAR KEPALA PEREMPUAN (cm) ==========
  static final WhoStandardData _headFemale = WhoStandardData(
    p3: [
      const FlSpot(0, 31.5), const FlSpot(1, 34.2), const FlSpot(2, 35.8),
      const FlSpot(3, 37.1), const FlSpot(4, 38.1), const FlSpot(5, 38.9),
      const FlSpot(6, 39.6), const FlSpot(7, 40.2), const FlSpot(8, 40.7),
      const FlSpot(9, 41.2), const FlSpot(10, 41.5), const FlSpot(11, 41.9),
      const FlSpot(12, 42.2), const FlSpot(15, 42.9), const FlSpot(18, 43.5),
      const FlSpot(21, 43.9), const FlSpot(24, 44.3), const FlSpot(30, 44.9),
      const FlSpot(36, 45.4), const FlSpot(42, 45.8), const FlSpot(48, 46.1),
      const FlSpot(54, 46.4), const FlSpot(60, 46.6),
    ],
    p50: [
      const FlSpot(0, 33.9), const FlSpot(1, 36.5), const FlSpot(2, 38.3),
      const FlSpot(3, 39.5), const FlSpot(4, 40.6), const FlSpot(5, 41.5),
      const FlSpot(6, 42.2), const FlSpot(7, 42.8), const FlSpot(8, 43.4),
      const FlSpot(9, 43.8), const FlSpot(10, 44.2), const FlSpot(11, 44.6),
      const FlSpot(12, 44.9), const FlSpot(15, 45.7), const FlSpot(18, 46.2),
      const FlSpot(21, 46.7), const FlSpot(24, 47.0), const FlSpot(30, 47.7),
      const FlSpot(36, 48.1), const FlSpot(42, 48.5), const FlSpot(48, 48.9),
      const FlSpot(54, 49.1), const FlSpot(60, 49.4),
    ],
    p97: [
      const FlSpot(0, 36.2), const FlSpot(1, 38.9), const FlSpot(2, 40.7),
      const FlSpot(3, 42.0), const FlSpot(4, 43.1), const FlSpot(5, 44.0),
      const FlSpot(6, 44.8), const FlSpot(7, 45.5), const FlSpot(8, 46.0),
      const FlSpot(9, 46.5), const FlSpot(10, 46.9), const FlSpot(11, 47.3),
      const FlSpot(12, 47.6), const FlSpot(15, 48.4), const FlSpot(18, 49.0),
      const FlSpot(21, 49.5), const FlSpot(24, 49.8), const FlSpot(30, 50.5),
      const FlSpot(36, 51.0), const FlSpot(42, 51.5), const FlSpot(48, 51.8),
      const FlSpot(54, 52.1), const FlSpot(60, 52.3),
    ],
  );
}

/// Data struktur untuk menyimpan kurva percentile WHO
class WhoStandardData {
  final List<FlSpot> p3;   // Persentil 3 (batas bawah normal)
  final List<FlSpot> p50;  // Persentil 50 (median)
  final List<FlSpot> p97;  // Persentil 97 (batas atas normal)

  const WhoStandardData({
    required this.p3,
    required this.p50,
    required this.p97,
  });
}
