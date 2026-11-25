import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/child_profile/data/models/child_model.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/child_profile/presentation/providers/child_provider.dart';

void main() {
  test(
    'Beranda memilih profil dari daftar model setelah tambah anak',
    () async {
      final snapshots = StreamController<List<ChildModel>>(sync: true);
      final container = ProviderContainer(
        overrides: [
          childrenStreamProvider.overrideWith((_) => snapshots.stream),
        ],
      );
      addTearDown(snapshots.close);
      addTearDown(container.dispose);

      ChildModel profile(String id) => ChildModel(
        id: id,
        parentId: 'parent',
        name: id,
        birthDate: DateTime(2024),
        createdAt: DateTime(2025),
        gender: Gender.female,
      );
      final first = profile('first');
      final added = profile('added');
      final initial = container.read(childrenStreamProvider.future);
      snapshots.add([first]);
      await initial;
      container.read(selectedChildIdProvider.notifier).state = first.id;
      snapshots.add([first, added]);
      expect(container.read(childListProvider), [first, added]);
      expect(container.read(selectedChildProvider), first);
      container.read(selectedChildIdProvider.notifier).state = added.id;
      expect(container.read(selectedChildProvider), added);
      container.read(selectedChildIdProvider.notifier).state = 'removed';
      expect(container.read(selectedChildProvider), first);
    },
  );
}
