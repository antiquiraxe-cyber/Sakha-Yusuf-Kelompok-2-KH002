import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/growth_record_entity.dart';

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

  factory GrowthRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final recordDate = data['recordDate'] is Timestamp
        ? (data['recordDate'] as Timestamp).toDate()
        : (data['recordDate'] is String
            ? DateTime.tryParse(data['recordDate'] as String) ?? DateTime.now()
            : DateTime.now());

    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : (data['createdAt'] is String
            ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
            : DateTime.now());

    return GrowthRecordModel(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      recordDate: recordDate,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
      heightCm: (data['heightCm'] as num?)?.toDouble() ?? 0.0,
      headCircumferenceCm: (data['headCircumferenceCm'] as num?)?.toDouble(),
      note: data['note'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'recordDate': Timestamp.fromDate(recordDate),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
      'note': note,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

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
