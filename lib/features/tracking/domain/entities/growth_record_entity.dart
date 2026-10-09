import 'package:equatable/equatable.dart';

class GrowthRecordEntity extends Equatable {
  final String id;
  final String childId;
  final DateTime recordDate;
  final double weightKg;       // Berat badan (kg)
  final double heightCm;       // Tinggi/Panjang badan (cm)
  final double? headCircumferenceCm; // Lingkar kepala (cm)
  final String? note;
  final String? photoUrl;
  final DateTime createdAt;

  const GrowthRecordEntity({
    required this.id,
    required this.childId,
    required this.recordDate,
    required this.weightKg,
    required this.heightCm,
    this.headCircumferenceCm,
    this.note,
    this.photoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        childId,
        recordDate,
        weightKg,
        heightCm,
        headCircumferenceCm,
        note,
        photoUrl,
        createdAt,
      ];
}
