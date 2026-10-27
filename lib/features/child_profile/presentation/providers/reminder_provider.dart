import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

        // Jadwalkan pengingat berkala
        await NotificationService.scheduleKpspReminder(
          id: notifId,
          childName: child.name,
          nextMilestoneAge: nextMilestone,
        );

        // Berikan notifikasi konfirmasi bahwa pengingat telah aktif
        await NotificationService.showNotification(
          id: 999,
          title: 'Pengingat KPSP Aktif 🔔',
          body:
              'Pengingat evaluasi tumbuh kembang untuk ${child.name} berhasil diaktifkan.',
        );
      }
    } else {
      // Batalkan seluruh jadwal pengingat jika toggle dimatikan
      await NotificationService.cancelAllReminders();
    }
  }

  int? _getNextMilestoneAge(int currentAgeMonths) {
    const kpspAges = [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60];
    for (final age in kpspAges) {
      if (age >= currentAgeMonths) return age;
    }
    return null;
  }
}

/// Provider global untuk status toggle pengingat KPSP
final reminderProvider =
    StateNotifierProvider<ReminderStateNotifier, bool>((ref) {
  return ReminderStateNotifier();
});
