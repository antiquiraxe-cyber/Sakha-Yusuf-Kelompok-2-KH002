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

  test('ChildEntity copyWith memperbarui field dengan benar', () {
    final now = DateTime.now();
    final child = ChildEntity(
      id: 'c3',
      parentId: 'u1',
      name: 'Budi',
      birthDate: DateTime(2023, 5, 10),
      gender: Gender.male,
      childOrder: 1,
      createdAt: now,
    );

    final updated = child.copyWith(
      name: 'Budi Santoso',
      gender: Gender.female,
    );

    expect(updated.id, 'c3');
    expect(updated.name, 'Budi Santoso');
    expect(updated.gender, Gender.female);
    expect(updated.birthDate, DateTime(2023, 5, 10));
  });

  test('ageInMonthsAt memakai tanggal pengukuran, bukan hari ini', () {
    final child = ChildEntity(
      id: 'c4',
      parentId: 'u1',
      name: 'Budi',
      birthDate: DateTime(2024, 1, 10),
      gender: Gender.male,
      createdAt: DateTime(2024, 1, 10),
    );

    expect(child.ageInMonthsAt(DateTime(2024, 4, 9)), 2);
    expect(child.ageInMonthsAt(DateTime(2024, 4, 10)), 3);
    expect(child.ageInMonthsAt(DateTime(2025, 1, 10)), 12);
    // Tanggal sebelum lahir tidak boleh menghasilkan usia negatif.
    expect(child.ageInMonthsAt(DateTime(2023, 12, 1)), 0);
  });
}
