import 'package:langkahawal/features/tracking/domain/entities/growth_record_entity.dart';

class GrowthRecordModel extends GrowthRecordEntity {
  const GrowthRecordModel({
    required super.id,
    required super.childId,
    required super.recordDate,
    required super.weightKg,
    required super.heightCm,
    super.headCircumferenceCm,
    super.note,
    super.photoUrl,
    required super.createdAt,
  });

  factory GrowthRecordModel.fromJson(Map<String, dynamic> json) {
    return GrowthRecordModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      recordDate: DateTime.parse(json['recordDate'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      headCircumferenceCm: json['headCircumferenceCm'] != null
          ? (json['headCircumferenceCm'] as num).toDouble()
          : null,
      note: json['note'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'recordDate': recordDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
      'note': note,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
