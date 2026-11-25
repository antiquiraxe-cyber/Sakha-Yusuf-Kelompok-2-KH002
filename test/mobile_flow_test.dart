import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langkahawal/core/theme/app_theme.dart';
import 'package:langkahawal/features/auth/presentation/providers/auth_provider.dart';
import 'package:langkahawal/features/child_profile/domain/entities/child_entity.dart';
import 'package:langkahawal/features/child_profile/data/models/child_model.dart';
import 'package:langkahawal/features/child_profile/presentation/providers/child_provider.dart';
import 'package:langkahawal/features/child_profile/presentation/screens/child_list_screen.dart';
import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';
import 'package:langkahawal/features/milestone/domain/repositories/milestone_repository.dart';
import 'package:langkahawal/features/milestone/presentation/providers/milestone_provider.dart';
import 'package:langkahawal/features/milestone/presentation/screens/milestone_screen.dart';
import 'package:langkahawal/features/milestone/presentation/screens/milestone_timeline_screen.dart';
import 'package:langkahawal/features/tracking/domain/entities/growth_record_entity.dart';
import 'package:langkahawal/features/tracking/domain/repositories/growth_record_repository.dart';
import 'package:langkahawal/features/tracking/presentation/providers/growth_record_provider.dart';
import 'package:langkahawal/features/tracking/presentation/screens/growth_chart_screen.dart';
import 'package:langkahawal/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:langkahawal/shared/widgets/child_summary_card.dart';

final child = ChildEntity(
  id: 'a',
  parentId: 'parent',
  name: 'Alya',
  birthDate: DateTime.now().subtract(const Duration(days: 125)),
  gender: Gender.female,
  createdAt: DateTime.now(),
);

class _Milestones extends Fake implements MilestoneRepository {
  final attempts = <MilestoneResultEntity>[];
  final pending = Completer<void>();
  @override
  Future<void> saveMilestoneResult(MilestoneResultEntity result) async {
    attempts.add(result);
    if (attempts.length == 1) throw StateError('offline');
    await pending.future;
  }

  @override
  Stream<List<MilestoneResultEntity>> watchMilestoneHistory(String childId) =>
      Stream.value(attempts.isEmpty ? [] : [attempts.last]);
}

class _Growth extends Fake implements GrowthRecordRepository {
  final records = StreamController<List<GrowthRecordEntity>>.broadcast();
  GrowthRecordEntity? saved;
  @override
  Stream<List<GrowthRecordEntity>> watchRecords(String childId) async* {
    yield [];
    yield* records.stream;
  }

  @override
  Future<void> addRecord(GrowthRecordEntity record) async {
    saved = record;
    records.add([record]);
  }
}

Future<void> phone(
  WidgetTester tester,
  Widget home,
  List<Override> overrides, {
  GoRouter? router,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 720);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  Widget largeText(BuildContext context, Widget? page) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.5)),
    child: page!,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: router == null
          ? MaterialApp(
              theme: AppTheme.lightTheme,
              builder: largeText,
              home: home,
            )
          : MaterialApp.router(
              theme: AppTheme.lightTheme,
              builder: largeText,
              routerConfig: router,
            ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  testWidgets('Beranda kosong menyediakan aksi tambah profil', (tester) async {
    await phone(tester, const ChildListScreen(), [
      childrenStreamProvider.overrideWith((_) => Stream.value([])),
    ]);
    expect(find.text('Tambah Anak'), findsOneWidget);
  });

  testWidgets(
    'Ganti anak dari kartu dan prioritaskan evaluasi yang jatuh tempo',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final baby = ChildModel(
        id: 'b',
        name: 'Bima',
        parentId: child.parentId,
        createdAt: child.createdAt,
        gender: Gender.male,
        birthDate: DateTime.now(),
      );
      final original = ChildModel(
        id: child.id,
        name: child.name,
        parentId: child.parentId,
        createdAt: child.createdAt,
        gender: child.gender,
        birthDate: child.birthDate,
      );
      await phone(tester, const ChildListScreen(), [
        childrenStreamProvider.overrideWith(
          (_) => Stream.value(<ChildModel>[original, baby]),
        ),
        displayNameProvider.overrideWithValue('Ibu'),
        milestoneHistoryStreamProvider.overrideWith(
          (_, id) => Stream.value([]),
        ),
        latestGrowthRecordProvider.overrideWith((_, id) => null),
      ]);
      expect(find.text('Tambah Anak'), findsNothing);
      final due = find.text('Evaluasi KPSP sudah waktunya');
      expect(
        tester.getTopLeft(due).dy,
        lessThan(tester.getTopLeft(find.text('Berat')).dy),
      );
      await tester.tap(find.text('Alya'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Anak'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Bima'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bima'), findsOneWidget);
      expect(
        tester.widget<ChildSummaryCard>(find.byType(ChildSummaryCard)).child.id,
        baby.id,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChildListScreen)),
      );
      expect(container.read(selectedChildIdProvider), baby.id);
      expect(due, findsNothing);
      await tester.tap(find.text('Bima'));
      await tester.pumpAndSettle();
      expect(find.text('Alya'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Alya'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alya'), findsOneWidget);
      expect(find.text('Bima'), findsNothing);
      expect(
        tester.widget<ChildSummaryCard>(find.byType(ChildSummaryCard)).child.id,
        original.id,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Gagal simpan mempertahankan jawaban, retry hanya menyimpan satu sesi dan membuka riwayat',
    (tester) async {
      final repo = _Milestones();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const MilestoneScreen(childId: 'a'),
          ),
          GoRoute(
            path: '/history/:childId',
            name: 'milestoneTimeline',
            builder: (_, state) => MilestoneTimelineScreen(
              childId: state.pathParameters['childId']!,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await phone(tester, const SizedBox(), [
        childListProvider.overrideWithValue([child]),
        milestoneRepositoryProvider.overrideWithValue(repo),
        kpspQuestionsProvider.overrideWith(
          (_, age) => [
            MilestoneQuestionEntity(
              id: 'q',
              ageMonth: age,
              aspect: MilestoneAspect.social,
              question: 'Pertanyaan uji',
              stimulationTip: 'Petunjuk uji',
            ),
          ],
        ),
      ], router: router);
      await tester.tap(find.byTooltip('Tips stimulasi'));
      await tester.pumpAndSettle();
      expect(find.text('Petunjuk uji'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya'));
      await tester.pumpAndSettle();
      final save = find.text('Simpan hasil evaluasi');
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('Hasil gagal disimpan'), findsOneWidget);
      expect(find.text('Hasil tersimpan'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pump();
      expect(find.text('Menyimpan…'), findsOneWidget);
      repo.pending.complete();
      await tester.pumpAndSettle();
      expect(repo.attempts.first.id, repo.attempts.last.id);
      expect(repo.attempts.last.answers, {'q': true});
      expect(find.text('Hasil tersimpan'), findsOneWidget);
      await tester.ensureVisible(find.text('Lihat riwayat KPSP'));
      await tester.tap(find.text('Lihat riwayat KPSP'));
      await tester.pumpAndSettle();
      expect(find.text('Timeline Milestone'), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget);
    },
  );

  testWidgets(
    'Catatan menerima koma dan titik dan menampilkan pengukuran tersimpan',
    (tester) async {
      final repo = _Growth();
      addTearDown(repo.records.close);
      await phone(tester, const TrackingScreen(childId: 'a'), [
        childListProvider.overrideWithValue([child]),
        growthRecordRepositoryProvider.overrideWithValue(repo),
      ]);
      expect(find.text('Alya'), findsOneWidget);
      for (final (i, value) in ['6,5', '64.5', '42,5'].indexed) {
        await tester.enterText(find.byType(TextFormField).at(i), value);
      }
      final save = find.text('Simpan Catatan');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.saved?.weightKg, 6.5);
      expect(repo.saved?.heightCm, 64.5);
      expect(repo.saved?.headCircumferenceCm, 42.5);
      expect(find.text('Data telah berhasil disimpan'), findsOneWidget);
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await tester.pumpAndSettle();
      expect(find.text('BB: 6.5 kg').hitTestable(), findsOneWidget);
    },
  );

  testWidgets(
    'Grafik fisik satu catatan menampilkan titik dan keterangan tren',
    (tester) async {
      final now = DateTime.now();
      final measurement = GrowthRecordEntity(
        id: 'one',
        childId: 'a',
        recordDate: now,
        weightKg: 6.5,
        heightCm: 64.5,
        createdAt: now,
      );
      await phone(tester, const GrowthChartScreen(childId: 'a'), [
        childListProvider.overrideWithValue([child]),
        growthRecordsStreamProvider.overrideWith(
          (_, id) => Stream.value([measurement]),
        ),
        milestoneHistoryStreamProvider.overrideWith(
          (_, id) => Stream.value([]),
        ),
      ]);
      expect(
        find.text('Butuh minimal 2 catatan untuk melihat tren.'),
        findsWidgets,
      );
      expect(
        tester
            .widget<LineChart>(find.byType(LineChart).first)
            .data
            .lineBarsData
            .last
            .spots
            .single
            .y,
        6.5,
      );
    },
  );

  testWidgets('Grafik KPSP tetap bisa dibuka tanpa catatan fisik', (
    tester,
  ) async {
    final history = StreamController<List<MilestoneResultEntity>>();
    addTearDown(history.close);
    await phone(tester, const GrowthChartScreen(childId: 'a'), [
      childListProvider.overrideWithValue([child]),
      growthRecordsStreamProvider.overrideWith((_, id) => Stream.value([])),
      milestoneHistoryStreamProvider.overrideWith((_, id) => history.stream),
    ]);
    await tester.ensureVisible(find.text('KPSP'));
    await tester.tap(find.text('KPSP'));
    history.add([]);
    await tester.pumpAndSettle();
    expect(find.textContaining('Belum ada hasil KPSP'), findsOneWidget);
    history.add([
      MilestoneResultEntity(
        id: 'one',
        childId: 'a',
        ageMonthEvaluated: 3,
        answers: const {'q': true},
        totalYes: 1,
        status: MilestoneStatus.sesuai,
        evaluatedAt: DateTime(2026, 6, 1),
      ),
    ]);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BarChart>(find.byType(BarChart))
          .data
          .barGroups
          .single
          .barRods
          .single
          .toY,
      100,
    );
    expect(find.text('1/1 Ya · 100% · Sesuai'), findsOneWidget);
  });
}
