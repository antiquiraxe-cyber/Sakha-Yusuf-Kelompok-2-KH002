import 'package:equatable/equatable.dart';

enum MilestoneAspect {
  grossMotor, // Motorik Kasar
  fineMotor,  // Motorik Halus
  speech,     // Bicara & Bahasa
  social,     // Sosialisasi & Kemandirian
}

enum MilestoneStatus {
  sesuai,       // 9 - 10 'Ya'
  meragukan,    // 7 - 8 'Ya'
  penyimpangan, // < 7 'Ya'
}

class MilestoneQuestionEntity extends Equatable {
  final String id;
  final int ageMonth;
  final MilestoneAspect aspect;
  final String question;
  final String? stimulationTip;
  final bool isRedFlag;

  const MilestoneQuestionEntity({
    required this.id,
    required this.ageMonth,
    required this.aspect,
    required this.question,
    this.stimulationTip,
    this.isRedFlag = false,
  });

  @override
  List<Object?> get props => [id, ageMonth, aspect, question, stimulationTip, isRedFlag];
}

class MilestoneResultEntity extends Equatable {
  final String id;
  final String childId;
  final int ageMonthEvaluated;
  final Map<String, bool> answers; // questionId -> true (Ya) / false (Tidak)
  final int totalYes;
  final MilestoneStatus status;
  final DateTime evaluatedAt;

  const MilestoneResultEntity({
    required this.id,
    required this.childId,
    required this.ageMonthEvaluated,
    required this.answers,
    required this.totalYes,
    required this.status,
    required this.evaluatedAt,
  });

  static MilestoneStatus calculateStatus(int totalYes, int totalQuestions) {
    final ratio = totalYes / totalQuestions;
    if (ratio >= 0.9) return MilestoneStatus.sesuai;
    if (ratio >= 0.7) return MilestoneStatus.meragukan;
    return MilestoneStatus.penyimpangan;
  }

  @override
  List<Object?> get props => [id, childId, ageMonthEvaluated, answers, totalYes, status, evaluatedAt];
}
