# 📋 Laporan Pengerjaan Tugas: Frontend (States)
**Proyek:** LangkahAwal — Aplikasi Pemantau Tumbuh Kembang Anak  
**Tim:** Kelompok 2 - KH002  
**Nama Anggota:** Nunes  
**Peran (Role):** Frontend (States)  
**Project Manager:** Sakha Yusuf Pasha  
**Tanggal Penyelesaian:** 28 Oktober 2026  
**Status Tugas:** ✅ **SELESAI (100% Tuntas & Sudah Ter-Push ke GitHub)**

---

## 1. Ringkasan Eksekutif & Tupoksi

Berdasarkan dokumen pembagian kerja tim Kelompok 2 - KH002, peran **Nunes** berfokus pada implementasi komponen antarmuka pengguna untuk menangani ketiga status utama aplikasi (**Loading State**, **Empty State**, dan **Error/Offline State**), serta mengintegrasikan pola *reactive state handling* berbasis Riverpod pada layar utama dashboard ([`ChildListScreen`](lib/features/child_profile/presentation/screens/child_list_screen.dart)).

Seluruh target pengerjaan telah berhasil diselesaikan secara tuntas dan telah diunggah ke remote repository GitHub pada branch `feat/states`. Kode telah diverifikasi menggunakan `flutter analyze` dengan hasil **0 issues** (bersih dari warning dan error), serta seluruh pengujian otomatis lulus 100% (**21/21 tests pass**).

---

## 2. Rincian Implementasi Teknis

### A. Animasi Loading Shimmer & Reusable Skeleton Loader
Berkas: `lib/shared/widgets/skeleton_loader.dart` (Baru)
1. **`SkeletonShimmer` Engine**:
   - Menggunakan `AnimationController` dan `SingleTickerProviderStateMixin` murni Flutter (tanpa dependensi eksternal tambahan) untuk menghasilkan animasi *pulsing opacity* 60fps yang sangat halus (transisi *ease-in-out* dari 0.35 ke 0.85).
2. **Komponen Bangunan Skeleton (Atomic Components)**:
   - `SkeletonLine`: Placeholder persegi panjang dengan *border radius* untuk merepresentasikan baris teks atau label.
   - `SkeletonCircle`: Placeholder lingkaran untuk avatar foto profil anak dan ikon statistik.
   - `SkeletonBox`: Placeholder fleksibel untuk wadah card atau kartu informasi.
   - `SkeletonCard`: Pembungkus dengan elevasi Material 3 dan padding konsisten.
3. **`DashboardSkeletonLoader`**:
   - Layout komposit lengkap yang mencerminkan tata letak dashboard utama secara presisi (Header Greeting, Kartu Profil Anak, 3 Kolom Statistik Tumbuh Kembang, Banner Evaluasi Gizi, Tombol Aksi Cepat, dan Kartu Pengingat). Memberikan pengalaman transisi visual yang mulus sebelum data Firestore selesai dimuat.

### B. Penanganan Kondisi Error & Offline (`ErrorStateWidget`)
Berkas: `lib/shared/widgets/error_state_widget.dart` (Baru)
1. **Desain Visual & UX Ramah Pengguna**:
   - Ikon peringatan terpusat (`Icons.error_outline_rounded`) dengan wadah beraksen merah lembut (`errorContainer`) agar tidak mengintimidasi orang tua.
   - Judul error informatif: *"Gagal Memuat Data"*.
   - Deskripsi yang menenangkan dan solutif: *"Terjadi kendala saat memuat data. Pastikan perangkat Anda terhubung ke internet dan coba beberapa saat lagi."*
2. **Tombol Pemulihan ("Coba Lagi")**:
   - Tombol `FilledButton.icon` dengan target sentuh *thumb-friendly* (ketinggian minimal 52dp) yang langsung memicu fungsi *callback* pembaruan data (`onRetry`).

### C. Standardisasi & Refinement `EmptyStateWidget`
Berkas: `lib/shared/widgets/empty_state_widget.dart` (Diperbarui)
1. **Fleksibilitas Aksi**:
   - Penambahan parameter `actionIcon` (default `Icons.add`) agar widget dapat digunakan untuk konteks data kosong lainnya di seluruh aplikasi (misal riwayat timbangan atau milestone).
2. **Proteksi Responsivitas Layar**:
   - Pembungkusan konten dengan `SingleChildScrollView` dan padding 32dp untuk mencegah terjadinya error *pixel overflow* pada perangkat Android berlayar kecil atau saat keyboard virtual aktif.

### D. Integrasi Reactive di `ChildListScreen` & Polishing UI
Berkas: `lib/features/child_profile/presentation/screens/child_list_screen.dart` (Diperbarui)
1. **Penerapan Pola `AsyncValue.when`**:
   - Mengganti pembacaan manual boolean `isLoading` dan *fallback* kosong `.value ?? []` dengan pola Riverpod standar:
     ```dart
     final childrenAsync = ref.watch(childrenStreamProvider);
     return childrenAsync.when(
       loading: () => const Scaffold(body: SafeArea(child: DashboardSkeletonLoader())),
       error: (error, stack) => Scaffold(
         body: SafeArea(
           child: ErrorStateWidget(
             title: 'Gagal Memuat Data',
             message: 'Terjadi kendala saat memuat data anak dari server...',
             actionLabel: 'Coba Lagi',
             onRetry: () => ref.invalidate(childrenStreamProvider),
           ),
         ),
       ),
       data: (children) => children.isEmpty 
           ? _buildEmptyState(context) 
           : _buildDashboardContent(context, children),
     );
     ```
   - Dengan alur ini, jika terjadi kegagalan jaringan atau penolakan hak akses Firestore, UI akan menampilkan `ErrorStateWidget` yang tepat, bukan keliru jatuh ke *Empty State*.
2. **Dukungan Gesture Pull-to-Refresh**:
   - Menambahkan widget `RefreshIndicator` di atas dashboard agar orang tua dapat menarik layar ke bawah (*swipe down to refresh*) untuk menyinkronkan data terbaru.
3. **Pembersihan Kode (Code Cleanup)**:
   - Menghapus kelas pembantu skeleton privat lama (`_buildLoadingSkeleton`, `_SkeletonLine`, `_SkeletonCircle`, `_SkeletonCard`) dari `child_list_screen.dart` sehingga kode menjadi modular dan mudah dirawat.

---

## 3. Daftar Berkas yang Dibuat & Dimodifikasi

| No | Lokasi Berkas | Status | Deskripsi |
|---|---|---|---|
| 1 | `lib/shared/widgets/skeleton_loader.dart` | **Created (Baru)** | Reusable skeleton shimmer engine, atomic components, & `DashboardSkeletonLoader` |
| 2 | `lib/shared/widgets/error_state_widget.dart` | **Created (Baru)** | Reusable widget tampilan error / offline dengan tombol "Coba Lagi" |
| 3 | `lib/shared/widgets/empty_state_widget.dart` | Modified | Peningkatan responsivitas scroll dan fleksibilitas kustomisasi `actionIcon` |
| 4 | `lib/features/child_profile/presentation/screens/child_list_screen.dart` | Modified | Integrasi `childrenAsync.when`, pull-to-refresh, dan refactoring modul skeleton |
| 5 | `test/states_widget_test.dart` | **Created (Baru)** | Unit & widget test suite khusus pengujian ketiga state (Loading, Empty, Error) |

---

## 4. Hasil Verifikasi, Linting, & Pengujian

### A. Static Code Analysis (`flutter analyze`)
```text
Analyzing File Praktikum Pemrograman Mobile smt5...
No issues found! (ran in 4.8s)
```
> **Hasil:** 0 error, 0 warning, 0 linter hint. Kode bersih 100%.

### B. Automated Testing (`flutter test`)
```text
00:00 +0: EmptyStateWidget Tests menampilkan title, deskripsi, dan tombol CTA dengan benar
00:00 +1: ErrorStateWidget Tests menampilkan judul, pesan error, dan memanggil onRetry saat diklik
00:00 +2: SkeletonLoader Tests DashboardSkeletonLoader dapat dirender dengan mulus tanpa error
...
00:01 +21: All tests passed!
```
> **Hasil:** Seluruh 21 test case (termasuk ChildModel, KPSP Question Bank, GrowthEvaluationService, GrowthEvaluationSheet, dan States Widgets) lulus tanpa kegagalan.

---

## 5. Version Control & Pull Request

* **Branch Asal:** `feat/states`
* **Target Branch:** `main`
* **Pesan Commit:** `feat: implementasi loading skeleton shimmer, error state widget, dan integrasi AsyncValue di ChildListScreen`
* **Remote Status:** Berhasil di-push ke `origin/feat/states`
* **Tautan Pull Request (GitHub):**  
  👉 [https://github.com/antiquiraxe-cyber/Sakha-Yusuf-Kelompok-2-KH002/pull/new/feat/states](https://github.com/antiquiraxe-cyber/Sakha-Yusuf-Kelompok-2-KH002/pull/new/feat/states)

---

## 6. Panduan Pengujian untuk QA (Hana)

1. **Pengujian Loading State (Shimmer Skeleton):**
   - Buka aplikasi atau lakukan logout lalu login kembali.
   - **Ekspektasi:** Saat aplikasi sedang berkomunikasi dengan Firestore untuk pertama kali, animasi skeleton shimmer yang halus akan tampil di layar utama menyerupai tata letak dashboard sebelum kartu profil anak muncul.
2. **Pengujian Empty State:**
   - Login menggunakan akun baru yang belum mendaftarkan anak, atau hapus seluruh data anak.
   - **Ekspektasi:** Muncul tampilan ikon anak besar dengan teks panduan dan tombol CTA *"Tambah Anak"*. Menekan tombol akan mengarahkan pengguna ke halaman registrasi anak.
3. **Pengujian Error / Offline State:**
   - Matikan koneksi internet (Airplane Mode / matikan Wi-Fi dan Data) sebelum login atau sebelum data dashboard termuat.
   - **Ekspektasi:** Tampil `ErrorStateWidget` dengan ikon peringatan berwarna merah lembut dan tombol *"Coba Lagi"*.
   - Nyalakan kembali koneksi internet, lalu tekan tombol *"Coba Lagi"*. Layar akan otomatis memuat ulang data anak.
4. **Pengujian Pull-to-Refresh:**
   - Pada halaman dashboard anak, tarik layar ke bawah (*swipe down*).
   - **Ekspektasi:** Indikator penyegaran (*refresh indicator*) berputar dan data realtime anak dari Firestore berhasil disinkronkan ulang.
