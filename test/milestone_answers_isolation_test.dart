import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langkahawal/features/milestone/presentation/providers/milestone_provider.dart';

void main() {
  test('jawaban KPSP tidak bocor antar anak', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(milestoneAnswersProvider('anakA:12').notifier)
        .setAnswer('q1', true);

    expect(container.read(milestoneAnswersProvider('anakA:12')), {'q1': true});
    expect(container.read(milestoneAnswersProvider('anakB:12')), isEmpty);

    // Reset hanya membersihkan milik anak A.
    container.read(milestoneAnswersProvider('anakA:12').notifier).reset();
    expect(container.read(milestoneAnswersProvider('anakA:12')), isEmpty);
  });

  test('kelompok usia berbeda punya sesi jawaban sendiri', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(milestoneAnswersProvider('anakA:12').notifier)
        .setAnswer('q1', true);

    expect(container.read(milestoneAnswersProvider('anakA:15')), isEmpty);
  });
}
