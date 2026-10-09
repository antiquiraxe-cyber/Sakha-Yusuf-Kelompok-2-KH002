class AppConstants {
  AppConstants._();

  static const String appName = 'LangkahAwal';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';
  static const String milestonesCollection = 'milestones';
  static const String recordsCollection = 'records';
  static const String todoCollection = 'todos';

  // Secure Storage Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';

  // Usia anak dalam bulan yang didukung KPSP
  static const List<int> kpspAgeMonths = [
    3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60
  ];
}
