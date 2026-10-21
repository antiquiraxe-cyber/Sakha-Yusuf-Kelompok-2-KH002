import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/milestone_entity.dart';

class MilestoneResultModel extends MilestoneResultEntity {
  const MilestoneResultModel({
    required super.id,
    required super.childId,
    required super.ageMonthEvaluated,
    required super.answers,
    required super.totalYes,
    required super.status,
    required super.evaluatedAt,
  });

  factory MilestoneResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawAnswers = data['answers'] as Map<String, dynamic>? ?? {};
    final answers = rawAnswers.map((k, v) => MapEntry(k, v as bool));

    final statusString = data['status'] as String? ?? 'sesuai';
    final status = MilestoneStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => MilestoneStatus.sesuai,
    );

    final evaluatedAt = data['evaluatedAt'] is Timestamp
        ? (data['evaluatedAt'] as Timestamp).toDate()
        : (data['evaluatedAt'] is String
            ? DateTime.tryParse(data['evaluatedAt'] as String) ?? DateTime.now()
            : DateTime.now());

    return MilestoneResultModel(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      ageMonthEvaluated: data['ageMonthEvaluated'] as int? ?? 0,
      answers: answers,
      totalYes: data['totalYes'] as int? ?? 0,
      status: status,
      evaluatedAt: evaluatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'ageMonthEvaluated': ageMonthEvaluated,
      'answers': answers,
      'totalYes': totalYes,
      'status': status.name,
      'evaluatedAt': Timestamp.fromDate(evaluatedAt),
    };
  }

  factory MilestoneResultModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    final answers = rawAnswers.map((k, v) => MapEntry(k, v as bool));

    final statusString = json['status'] as String? ?? 'sesuai';
    final status = MilestoneStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => MilestoneStatus.sesuai,
    );

    return MilestoneResultModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      ageMonthEvaluated: json['ageMonthEvaluated'] as int,
      answers: answers,
      totalYes: json['totalYes'] as int,
      status: status,
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'ageMonthEvaluated': ageMonthEvaluated,
      'answers': answers,
      'totalYes': totalYes,
      'status': status.name,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }
}
