# LAPORAN PROGRES KERJA SAKHA (PM + BACKEND AUTH & CHILD)
**Proyek:** LangkahAwal — Aplikasi Pemantauan Tumbuh Kembang Anak (0–5 Tahun)  
**Role:** Project Manager + Backend (Auth & Child Profile)  
**Tanggal Update:** 16 Oktober 2026  
**Status:** ✅ **100% SELESAI (Ahead of Schedule)**

---

## 1. Ringkasan Eksekutif
Seluruh tupoksi dasar Sakha (Authentication, Firestore Child Profile, Navigation Guard) beserta fitur tambahan dari dosen (Engine Antropometri Deteksi Stunting & Obesitas **dengan saran gizi spesifik per kelompok usia** standar Kemenkes RI) telah berhasil diimplementasikan dan diuji dengan status **bersih (0 issue linting, 14/14 unit test lulus)**.

Teman-teman tim (Faisal, Nopal, Nunes, Raka, Hana) dapat langsung melakukan `git pull origin main` dan mulai mengerjakan tupoksi masing-masing tanpa ada blocker.

---

## 2. Rincian Fitur & Modul yang Selesai Dibuat

### A. Autentikasi Pengguna (Firebase Auth & Firestore)
* **Login & Registrasi:**
  * Form login dan pendaftaran akun ibu (`login_screen.dart`, `register_screen.dart`).
  * Validasi input format email, panjang sandi minimal 6 karakter, konfirmasi sandi, dan toggle intip kata sandi (👁️).
  * Pemetaan pesan error ramah pengguna dalam Bahasa Indonesia (misal: email salah, password lemah, akun dinonaktifkan).
* **Integrasi Firestore Profil:**
  * Begitu user mendaftar/login, data profil langsung tersimpan di koleksi `users/{uid}` berisi `name`, `email`, dan `createdAt`.
* **State Management Riverpod:**
  * Tersedia `authRepositoryProvider`, `authStateChangesProvider`, dan `currentUserProvider` di `auth_provider.dart`.

### B. Manajemen Data Profil Anak (Firestore CRUD)
* **Koleksi Firestore:** Data tersimpan pada path `users/{uid}/children/{childId}`.
* **ChildRepository & Model:**
  * Operasi `addChild()`, `getChildren()`, `watchChildren()`, `updateChild()`, dan `deleteChild()`.
  * Konversi timestamp Firestore otomatis dengan kalkulasi umur dinamis (`ageInMonths` dan `ageFormatted`).
* **Realtime Stream:**
  * Mengganti seluruh data dummy dengan `childrenStreamProvider` dan `selectedChildProvider`.
  * Form `AddChildScreen` otomatis menggunakan UID asli ibu yang sedang login (bukan mock `parent_001`).
* **Dashboard States:**
  * Terpasang skeleton loading saat fetching Firestore, empty state saat data kosong, dan greeting nama personal di dashboard (*"Selamat Siang, [Nama Ibu]"*).

### C. Navigasi & Proteksi Rute (GoRouter Guard)
* **Rute Awal:** Aplikasi terbuka di halaman `/login`.
* **Route Guard:**
  * User yang belum login otomatis diarahkan ke `/login` jika mencoba masuk ke halaman dalam.
  * User yang sudah login otomatis dialihkan dari halaman login ke `/home`.
* **Navigasi Bawah Dinamis (Bottom Bar):**
  * Ikon *Beranda* $\rightarrow$ kembali ke Dashboard.
  * Ikon *Milestone* $\rightarrow$ otomatis membuka evaluasi KPSP anak yang sedang aktif (`/milestone/:childId`).
  * Ikon *Catatan* $\rightarrow$ otomatis membuka form pencatatan fisik anak yang sedang aktif (`/tracking/:childId`).
  * Jika belum ada data anak, sistem memberikan notifikasi ramah agar ibu menambah anak terlebih dahulu.

### D. Engine Antropometri & Alert Rekomendasi Gizi Berbasis Usia Klinis (Saran Dosen)
Menjawab arahan dosen mengenai deteksi anomali fisik anak secara medis dengan diferensiasi usia:
* **Service:** `GrowthEvaluationService` (`lib/features/tracking/domain/services/growth_evaluation_service.dart`).
* **Standar Acuan:** Standar Antropometri Anak Kemenkes RI (Permenkes No. 2 Tahun 2020) & WHO Child Growth Standards (0–60 bulan).
* **Fitur Deteksi:**
  * **TB/U (Tinggi Badan menurut Umur):** Deteksi otomatis **Stunting Berat / Sangat Pendek** ($Z < -3\text{ SD}$), **Pendek** ($-3 \le Z < -2\text{ SD}$), dan **Normal**.
  * **BB/U (Berat Badan menurut Umur):** Deteksi **Gizi Buruk / Berat Sangat Kurang**, **Gizi Kurang**, dan **Normal**.
  * **Status Gizi Lebih & Obesitas:** Deteksi risiko berat badan berlebih dan **Obesitas** ($Z > +3\text{ SD}$).
* **Rekomendasi Makanan Sesuai Fase Usia Anak (Age-Bracketed MPASI & Gizi Balita):**
  1. **Usia 0–5 Bulan (Fase ASI Eksklusif):**
     * Optimasi ASI on-demand (8–12x/hari) & perlekatan (*latch-on*) hindmilk kaya lemak.
     * Nutrisi ibu menyusui (tinggi protein & cairan 3L).
     * *Peringatan Kemenkes:* Dilarang memberikan air putih, madu, atau makanan padat sebelum genap 6 bulan.
  2. **Usia 6–11 Bulan (Fase MPASI Awal — Tekstur Lumat & Saring):**
     * Protein hewani lumat: Hati ayam kukus blender, kuning telur rebus lumat, ikan kembung cincang halus.
     * Penambah kalori sehat: 1 sdt santan, minyak kelapa, atau mentega tawar (*unsalted butter*).
     * Tekstur lumat saring bertahap naik ke cincang halus.
  3. **Usia 12–23 Bulan / 1 Tahun (Fase MPASI Lanjutan — Makanan Lembek/Cincang):**
     * Wajib **1 butir telur ayam utuh per hari** + lauk hewani padat (pepes lele/kembung tanpa duri, bakso sapi empuk).
     * Camilan padat kalori (puding santan telur, perkedel kentang daging).
     * Disiplin aturan makan (*Feeding Rules*): 3x makan utama, 2x selingan, waktu makan maks 30 menit.
     * Batasi susu maks 400–500 ml/hari agar tidak kenyang susu.
  4. **Usia 24–59 Bulan / 2–5 Tahun (Fase Makanan Keluarga):**
     * Menu keluarga 2 jenis protein hewani berbeda sehari (telur + ayam/daging/ikan).
     * Siasati porsi dengan kuah santan atau keju parut.
     * *Obesitas:* Prinsip *"Isi Piringku Balita"* (1/3 karbo, 1/3 sayur-buah, 1/3 protein rendah lemak), stop minuman manis kemasan & fast food, aktif fisik 60 menit/hari.
* **UX Ramah Ibu:**
  * Form pengisian angka tetap bersih dan tenang tanpa alarm saat ibu mengetik.
  * Setelah data berhasil disimpan, sistem memunculkan **Bottom Sheet Edukatif** yang menampilkan hasil evaluasi dan saran makanan spesifik usia secara tenang dan solutif.
  * **Alur simpan aman:** Data disimpan (`addRecord`) **sebelum** bottom sheet muncul. Tombol "Mengerti & Selesai" hanya menutup sheet — jadi catatan tetap tersimpan meski ibu langsung swipe-tutup tanpa membaca saran.

---

## 3. Daftar File yang Dibuat / Dimodifikasi Sakha

| Path File | Keterangan |
| :--- | :--- |
| `lib/main.dart` | Inisialisasi Firebase & lokal Bahasa Indonesia |
| `lib/firebase_options.dart` | Konfigurasi platform Firebase Web & Android |
| `lib/core/routing/app_router.dart` | Redirect auth guard & bottom nav dynamic child routing |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Implementasi FirebaseAuth + sinkronisasi Firestore user |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Provider auth & stream user |
| `lib/features/auth/presentation/screens/login_screen.dart` | UI Login lengkap dengan validasi & error handling |
| `lib/features/auth/presentation/screens/register_screen.dart` | UI Register akun baru |
| `lib/features/child_profile/domain/repositories/child_repository.dart` | Kontrak interface repository profil anak |
| `lib/features/child_profile/data/repositories/child_repository_impl.dart` | Implementasi Firestore CRUD anak `users/{uid}/children` |
| `lib/features/child_profile/presentation/providers/child_provider.dart` | StreamProvider realtime anak & selected child |
| `lib/features/child_profile/presentation/screens/add_child_screen.dart` | Form tambah anak terhubung ke UID user asli |
| `lib/features/child_profile/presentation/screens/child_list_screen.dart` | Tombol logout, greeting nama, & proteksi rute |
| `lib/features/tracking/domain/services/growth_evaluation_service.dart` | Kalkulator Z-score Kemenkes/WHO & rekomendasi gizi |
| `lib/features/tracking/presentation/screens/tracking_screen.dart` | Integrasi evaluasi gizi & bottom sheet hasil pemantauan |
| `test/growth_evaluation_service_test.dart` | Unit test 6 kasus: bayi 0-5bln ASI, MPASI 6-11bln, Yusuf 1th (50cm/5kg), balita 2-5th, obesitas 24bln, normal 12bln |
| `test/child_model_test.dart` | Unit test konversi model anak Firestore |

---

## 4. Panduan untuk Teman-Teman Tim (Next Actions)

### 📌 Untuk FAISAL (Backend Milestone + Growth):
1. UID user sudah tersedia di seluruh aplikasi lewat `FirebaseAuth.instance.currentUser?.uid`.
2. Kamu tinggal membuat `MilestoneRepositoryImpl` untuk menyimpan kuesioner KPSP ke `users/{uid}/children/{childId}/milestones`.
3. Kamu tinggal membuat `GrowthRecordRepositoryImpl` untuk menyimpan data timbangan ke `users/{uid}/children/{childId}/growth_records`.
4. **PENTING — Alur simpan sudah benar:** Di `TrackingScreen._saveRecord()` data sudah tersimpan lewat `addRecord(record)` **sebelum** bottom sheet evaluasi muncul. Tombol "Mengerti & Selesai" hanya `Navigator.pop()` (menutup sheet), bukan aksi simpan. Jadi saat kamu ganti `growthRecordsProvider` dari mock in-memory ke `StreamProvider` Firestore, **tidak perlu ubah logika `TrackingScreen`** — record akan otomatis persist dan muncul di riwayat, bahkan jika ibu menutup sheet dengan swipe.
5. Hubungkan catatan terakhir (`getLatestRecord`) ke widget `_buildGrowthStats` di `child_list_screen.dart` agar angka `— kg` dan `— cm` terisi angka riil.
6. Sediakan layar/list **Riwayat Catatan** yang membaca stream `growth_records` (urut tanggal terbaru) — data dari `addRecord` di atas akan langsung tampil di sini.

### 📌 Untuk NOPAL (Frontend Forms: Edit & Hapus Anak):
1. `ChildRepository` sudah siap pakai (`ref.read(childRepositoryProvider)`).
2. Kamu tinggal membuat `EditChildScreen` dan memanggil `repository.updateChild()`.
3. Pasang dialog konfirmasi hapus anak yang memanggil `repository.deleteChild(parentId, childId)`.

### 📌 Untuk NUNES (Frontend States):
1. Stream Firestore sudah terpasang di `childListProvider`.
2. Kamu bisa memoles tampilan shimmer loader dan empty state jika belum ada anak di `ChildListScreen`.

### 📌 Untuk RAKA (Frontend Notifications):
1. Setup local notification di `main.dart` dan pasang switch toggle pengingat di dashboard.

### 📌 Untuk HANA (QA + Dokumentasi):
1. Silakan jalankan `flutter test` (semua 14 unit test saat ini berstatus PASS).
2. Lakukan pengujian manual alur: Register $\rightarrow$ Tambah Anak $\rightarrow$ Catat Pertumbuhan (uji kasus anak normal dan kasus Yusuf 1 tahun 50cm/5kg untuk melihat alert stunting & saran protein).

---

## 5. Hasil Pengujian Teknis
* **`dart analyze`**: Clean (0 issue, 0 warning).
* **`flutter test`**: **14/14 PASSED** (KpspQuestionBank 6 tests, ChildModel 2 tests, GrowthEvaluationService 6 tests mencakup seluruh kelompok usia).
