import 'package:equatable/equatable.dart';

enum Gender { male, female }

class ChildEntity extends Equatable {
  final String id;
  final String parentId;
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final int childOrder;
  final String? photoUrl;
  final DateTime createdAt;

  const ChildEntity({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.childOrder = 1,
    this.photoUrl,
    required this.createdAt,
  });

  // Menghitung usia kronologis dalam bulan
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  // Menghitung usia kronologis dalam format string (misal: "1 tahun 2 bulan")
  String get ageFormatted {
    final months = ageInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years > 0 && remainingMonths > 0) {
      return '$years tahun $remainingMonths bulan';
    } else if (years > 0) {
      return '$years tahun';
    } else {
      return '$months bulan';
    }
  }

  ChildEntity copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    int? childOrder,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return ChildEntity(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      childOrder: childOrder ?? this.childOrder,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        parentId,
        name,
        birthDate,
        gender,
        childOrder,
        photoUrl,
        createdAt,
      ];
}
