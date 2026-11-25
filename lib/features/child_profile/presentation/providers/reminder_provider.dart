import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/child_entity.dart';

/// StateNotifier untuk mengelola status pengingat evaluasi KPSP
/// serta menyimpannya ke SharedPreferences.
class ReminderStateNotifier extends StateNotifier<bool> {
  ReminderStateNotifier() : super(false) {
    _loadPreference();
  }

  static const String _prefKey = 'kpsp_reminder_enabled';

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefKey) ?? false;
  }

  /// Mengaktifkan atau mematikan pengingat notifikasi KPSP.
  Future<void> toggleReminder({
    required bool enabled,
    ChildEntity? child,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    state = enabled;

    if (enabled) {
      if (child != null) {
        final notifId = child.id.hashCode;
        final nextMilestone = _getNextMilestoneAge(child.ageInMonths);
        final scheduledDate =
            nextMilestone == null ? null : _milestoneDate(child, nextMilestone);

        // Jadwalkan pengingat pada tanggal milestone KPSP berikutnya.
        if (scheduledDate != null) {
          await NotificationService.scheduleKpspReminder(
            id: notifId,
            childName: child.name,
            nextMilestoneAge: nextMilestone,
            scheduledDate: scheduledDate,
          );
        }

        // Berikan notifikasi konfirmasi bahwa pengingat telah aktif
        await NotificationService.showNotification(
          id: 999,
          title: 'Pengingat KPSP Aktif 🔔',
          body: scheduledDate == null
              ? 'Semua rentang usia KPSP untuk ${child.name} sudah terlewati.'
              : 'Pengingat evaluasi ${nextMilestone!} bulan untuk ${child.name} aktif.',
        );
      }
    } else {
      // Batalkan seluruh jadwal pengingat jika toggle dimatikan
      await NotificationService.cancelAllReminders();
    }
  }

  int? _getNextMilestoneAge(int currentAgeMonths) {
    for (final age in AppConstants.kpspAgeMonths) {
      if (age >= currentAgeMonths) return age;
    }
    return null;
  }

  /// Tanggal pengingat = tanggal anak mencapai usia milestone, jam 09:00.
  /// Kalau tanggal itu sudah lewat, ingatkan besok pagi.
  DateTime? _milestoneDate(ChildEntity child, int milestoneAge) {
    final target = DateTime(
      child.birthDate.year,
      child.birthDate.month + milestoneAge,
      child.birthDate.day,
      9,
    );
    final now = DateTime.now();
    if (target.isAfter(now)) return target;

    final tomorrow = now.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
  }
}

/// Provider global untuk status toggle pengingat KPSP
final reminderProvider =
    StateNotifierProvider<ReminderStateNotifier, bool>((ref) {
  return ReminderStateNotifier();
});
