import 'package:flutter/material.dart';

/// Tema LangkahAwal — diambil dari referensi desain kesehatan:
/// latar off-white hangat, teks & tombol charcoal, panel cyan muda,
/// aksen coral dan sage, bentuk kapsul dengan radius besar.
class AppTheme {
  AppTheme._();

  // Palet inti
  static const Color ink = Color(0xFF22231F); // charcoal, teks & tombol utama
  static const Color canvas = Color(0xFFF1F1EC); // latar off-white
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cyan = Color(0xFFC7E9F2);
  static const Color cyanStrong = Color(0xFF9BD9E8);
  static const Color coral = Color(0xFFE8663F);
  /// Versi coral gelap untuk teks kecil (kontras >= 4.5:1 di atas putih).
  static const Color coralText = Color(0xFFB44520);
  static const Color coralSoft = Color(0xFFFBE2D8);
  static const Color sage = Color(0xFF7F8F4E);
  static const Color sageSoft = Color(0xFFE6EAD4);
  static const Color muted = Color(0xFF6B6D64);

  // Alias lama supaya pemanggil yang sudah ada tetap jalan
  static const Color primaryColor = ink;
  static const Color secondaryColor = coral;
  static const Color backgroundColor = canvas;
  static const Color errorColor = Color(0xFFC0392B);
  static const Color warningColor = Color(0xFFB26B00);
  static const Color successColor = sage;

  // Status KPSP
  static const Color statusSesuai = Color(0xFF5F7038);
  static const Color statusMeragukan = Color(0xFFB26B00);
  static const Color statusPenyimpangan = Color(0xFFC0392B);

  // Spacing & radius
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double radiusS = 12.0;
  static const double radiusM = 18.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // Warna metrik — dipakai lintas layar (dashboard, catat, grafik)
  static const Color metricWeight = cyanStrong;
  static const Color metricHeight = coral;
  static const Color metricHead = sage;

  static const String fontFamily = 'Poppins';

  static ThemeData get lightTheme {
    final scheme = _scheme();
    final text = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: canvas,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ink),
        titleTextStyle: text.titleLarge?.copyWith(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: ink,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cyan,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cyan : const Color(0xFFA9ABA1),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? ink : const Color(0xFFA9ABA1),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
          shape: const StadiumBorder(),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          side: const BorderSide(color: ink, width: 1.2),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 44),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(44, 44),
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: text.labelLarge,
        shape: const StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: cyan,
        disabledColor: const Color(0xFFE9EAE1),
        labelStyle: text.labelMedium?.copyWith(color: ink),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: ink),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDFE0D6),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink,
        textColor: ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ink;
          return surfaceColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cyanStrong;
          return const Color(0xFFE9EAE1);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return const Color(0xFFDFE0D6);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ink,
        linearTrackColor: Color(0xFFE9EAE1),
        circularTrackColor: Color(0xFFE9EAE1),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: muted,
        indicatorColor: ink,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: cyan,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: text.bodyMedium?.copyWith(color: muted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: const Color(0xFF9A9C91)),
        labelStyle: text.bodyMedium?.copyWith(color: muted),
        prefixIconColor: ink,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFDFE0D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFDFE0D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: ink, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 1.6),
        ),
      ),
    );
  }

  static ColorScheme _scheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: ink,
      onPrimary: Colors.white,
      primaryContainer: cyan,
      onPrimaryContainer: ink,
      secondary: coral,
      onSecondary: Colors.white,
      secondaryContainer: coralSoft,
      onSecondaryContainer: Color(0xFF6B2410),
      tertiary: sage,
      onTertiary: Colors.white,
      tertiaryContainer: sageSoft,
      onTertiaryContainer: Color(0xFF2F3A16),
      error: errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFFF8D7D2),
      onErrorContainer: Color(0xFF5A160F),
      surface: surfaceColor,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerHighest: Color(0xFFE9EAE1),
      outline: Color(0xFF9A9C91),
      outlineVariant: Color(0xFFDFE0D6),
      inverseSurface: ink,
      onInverseSurface: canvas,
      inversePrimary: cyan,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
  }

  static TextTheme _textTheme() => const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleSmall: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      );
}
