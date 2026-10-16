import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/child_profile/data/models/child_model.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';

void main() {
  test('ChildModel toFirestore mengonversi field dengan benar', () {
    final birthDate = DateTime(2024, 1, 15);
    final createdAt = DateTime(2024, 2, 1);
    final model = ChildModel(
      id: 'c1',
      parentId: 'u1',
      name: 'Rian',
      birthDate: birthDate,
      gender: Gender.male,
      childOrder: 1,
      createdAt: createdAt,
    );

    final map = model.toFirestore();
    expect(map['parentId'], 'u1');
    expect(map['name'], 'Rian');
    expect(map['gender'], 'male');
    expect(map['childOrder'], 1);
  });

  test('ChildEntity menghitung ageInMonths dan ageFormatted dengan benar', () {
    final now = DateTime.now();
    final child = ChildEntity(
      id: 'c2',
      parentId: 'u1',
      name: 'Siti',
      birthDate: DateTime(now.year - 1, now.month, now.day),
      gender: Gender.female,
      createdAt: now,
    );

    expect(child.ageInMonths, 12);
    expect(child.ageFormatted, contains('1 tahun'));
  });
}
