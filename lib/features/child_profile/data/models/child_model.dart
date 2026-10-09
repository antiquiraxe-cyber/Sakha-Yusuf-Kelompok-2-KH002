import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/child_entity.dart';

class ChildModel extends ChildEntity {
  const ChildModel({
    required super.id,
    required super.parentId,
    required super.name,
    required super.birthDate,
    required super.gender,
    super.childOrder = 1,
    super.photoUrl,
    required super.createdAt,
  });

  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildModel(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: (data['gender'] as String? ?? 'male') == 'male' ? Gender.male : Gender.female,
      childOrder: data['childOrder'] as int? ?? 1,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender == Gender.male ? 'male' : 'female',
      'childOrder': childOrder,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
