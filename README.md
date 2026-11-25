# LangkahAwal

Aplikasi pemantauan tumbuh kembang anak: evaluasi KPSP, catatan antropometri
(berat, tinggi, lingkar kepala), evaluasi gizi berbasis standar WHO/Kemenkes,
grafik pertumbuhan, dan pengingat evaluasi lokal.

- Flutter 3.47 / Dart 3.13
- Riverpod untuk state management
- Firebase Auth, Cloud Firestore, Firebase Storage
- go_router untuk navigasi

## Menjalankan

```bash
flutter pub get
flutter run
```

Butuh `google-services.json` di `android/app/` dan konfigurasi Firebase di
`lib/firebase_options.dart`. Lihat `docs/TUTORIAL-KONEKSI-FIREBASE.md`.

## Struktur

```
lib/
  core/       tema, routing, service notifikasi, konstanta
  features/   auth, child_profile, milestone, tracking
  shared/     widget lintas fitur
```

Tiap fitur memakai lapisan `domain` (entity + kontrak repository),
`data` (model + implementasi Firestore/Storage), dan `presentation`
(provider + screen).

## Build

```bash
flutter build apk --release
```

Tanda tangan release dibaca dari `android/key.properties` (lihat
`android/key.properties.example`). Tanpa file itu, build memakai debug key.

## Deploy Firebase

```bash
firebase deploy --only firestore:rules,storage
```

## Kelompok 2 KH002

Sakha Yusuf Pasha (20240801052), Faisal, Nopal, Nunes, Raka, Hana.
