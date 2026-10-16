# 📋 Pembagian Tugas LangkahAwal

**Tim:** Kelompok 2 - KH002
**Tanggal:** 14 Oktober 2026
**Target Selesai:** 28 Oktober 2026

---

## 🔎 CARA PAKAI FILE INI (untuk tanya ke AI)

1. Copy seluruh isi file ini.
2. Paste ke AI (ChatGPT / Claude / Gemini / dll).
3. Tulis: **"Saya [Nama Kamu], jelasin tupoksi saya dan jelasin gimana mulai kerjanya."**

AI langsung tau peran kamu karena tiap bagian di bawah sudah dipisah per nama dan ada blok **"TUPOKSI [Nama]"** yang merangkum tugasmu.

> Contoh: _"Saya Nunes. Jelasin tupoksi saya dan langkah pertama yang harus saya kerjain."_

---

## 👥 Daftar Anggota & Peran

| Nama | Role | Beban |
|------|------|-------|
| Sakha Yusuf Pasha | PM + Backend (Auth + Child) | Berat |
| Faisal | Backend (Milestone + Growth) | Berat |
| Nopal | Frontend (Forms) | Ringan |
| Nunes | Frontend (States) | Ringan |
| Raka | Frontend (Notifications) | Ringan |
| Hana | QA + Dokumentasi | Ringan |

---

# 👑 SAKHA YUSUF PASHA

## TUPOKSI SAKHA
Kamu adalah **Project Manager + Backend (Auth + Child)**. Kamu yang paling pertama kerja, karena semua anggota lain butuh uid (ID user) dari login yang kamu bikin.

**Status:** ✅ **SELESAI (100% Tuntas - 16 Oktober 2026)**

### Yang sudah dikerjakan
1. **Setup Firebase** — project Firebase `langkah-awal-bik` aktif (Auth Email/Password, Firestore Database, Storage).
2. **Login & Register** — form Login dan Register lengkap dengan validasi, error mapping bahasa Indonesia, dan UI thumb-friendly.
3. **AuthRepository** — implement `signInWithEmailAndPassword`, `signUpWithEmailAndPassword`, `signOut`, `getCurrentUser` pakai FirebaseAuth dan sinkronisasi profile document `users/{uid}`.
4. **Routing & Route Guard** — `initialLocation` di `/login`, redirect otomatis jika belum login, dan navigasi bottom bar diarahkan dinamis ke anak yang aktif.
5. **ChildRepository** — implement `addChild`, `getChildren`, `watchChildren`, `updateChild`, `deleteChild` ke Firestore `users/{uid}/children`.
6. **Ganti mock → Firestore** — `childListProvider` dan `selectedChildProvider` tersambung ke `childrenStreamProvider` realtime Firestore. Form tambah anak menggunakan `user.uid` asli.
7. **Engine Antropometri & Saran Gizi Fisik Berbasis Usia** — implementasi `GrowthEvaluationService` standar WHO/Kemenkes (0-60 bulan) dengan diferensiasi saran gizi untuk 4 fase usia (0-5bln ASI, 6-11bln MPASI lumat, 12-23bln 1 tahun, 24-59bln balita) untuk deteksi otomatis Stunting & Obesitas.
8. **Testing & QA Dasar** — unit test suite KPSP, ChildModel, dan GrowthEvaluationService lulus 100% (14/14 tests pass).

### File yang dipegang
- `lib/main.dart` (inisialisasi Firebase & locale)
- `lib/firebase_options.dart` (konfigurasi web & android)
- `lib/core/routing/app_router.dart` (route guard & bottom nav dynamic)
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/register_screen.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/child_profile/domain/repositories/child_repository.dart`
- `lib/features/child_profile/data/repositories/child_repository_impl.dart`
- `lib/features/child_profile/presentation/providers/child_provider.dart`
- `lib/features/tracking/domain/services/growth_evaluation_service.dart`

---

# 🔥 FAISAL

## TUPOKSI FAISAL
Kamu adalah **Backend (Milestone + Growth)**. Kamu ngerjain semuanya yang berhubungan dengan penyimpanan data hasil evaluasi KPSP dan catatan pertumbuhan ke Firebase. **Auth dan Child sudah selesai oleh Sakha, kamu sudah bisa langsung mulai.**

**Status:** 🚀 **SIAP DIKERJAKAN (Target: 21 Oktober 2026)**

### Yang harus kamu kerjakan
1. **MilestoneRepository** — implement `saveMilestoneResult()` dan `getMilestoneHistory()` ke Firestore `users/{uid}/children/{childId}/milestones`.
2. **Update MilestoneScreen** — ganti penyimpanan hasil dari mock (`lastMilestoneResultProvider`) jadi panggil `repository.saveMilestoneResult()`.
3. **GrowthRecordRepository** — implement `uploadPhoto()` ke Firebase Storage, `addRecord()`, `getRecordsByChildId()`, `deleteRecord()` ke Firestore `users/{uid}/children/{childId}/growth_records`.
4. **Ganti mock → Firestore** — ubah `growthRecordsProvider` jadi StreamProvider Firestore, dan `TrackingScreen` simpan lewat repository.
5. **Hubungkan Angka Dashboard** — sambungkan catatan timbangan terbaru (`getLatestRecord`) ke widget `_buildGrowthStats` di `ChildListScreen` agar angka berat dan tinggi badan tidak lagi strip (`— kg`, `— cm`).
6. **Riwayat Catatan** — sediakan list riwayat catatan timbangan di bawah form pencatatan atau layar riwayat.
7. **Firestore Security Rules** — pasang rules di Firebase Console biar user cuma bisa akses datanya sendiri.
8. **Storage Rules** — batasi ukuran foto max 2MB dan hanya gambar.

### ⚠️ Catatan Teknis Penting (dari Sakha)
- **Alur simpan sudah benar, jangan diubah.** Di `TrackingScreen._saveRecord()`, data tersimpan lewat `addRecord(record)` **sebelum** bottom sheet evaluasi gizi muncul. Tombol **"Mengerti & Selesai"** hanya menjalankan `Navigator.pop()` untuk menutup sheet — bukan aksi simpan.
- **Konsekuensi:** begitu kamu ganti `growthRecordsProvider` dari mock in-memory ke `StreamProvider` Firestore, record **otomatis** persist ke Firestore dan muncul di riwayat, bahkan jika ibu menutup sheet dengan swipe ke bawah (tanpa klik tombol). Kamu **tidak perlu** menyentuh logika `_saveRecord()`.
- Cukup ganti isi `GrowthRecordRepositoryImpl` + provider; UI `TrackingScreen` sudah siap.

### File yang kamu pegang
- `lib/features/milestone/data/repositories/milestone_repository_impl.dart`
- `lib/features/milestone/presentation/screens/milestone_screen.dart`
- `lib/features/tracking/data/repositories/growth_record_repository_impl.dart`
- `lib/features/tracking/presentation/providers/growth_record_provider.dart`
- `lib/features/tracking/presentation/screens/tracking_screen.dart`
- `lib/features/child_profile/presentation/screens/child_list_screen.dart` (bagian `_buildGrowthStats`)

### Deadline
**21 Oktober 2026**

---

# ✏️ NOPAL

## TUPOKSI NOPAL
Kamu adalah **Frontend (Forms)**. Kamu ngerjain tampilan buat **edit dan hapus profil anak**. **Tunggu Sakha selesai ChildRepository** (karena edit/hapus butuh repository yang udah jalan).

### Yang harus kamu kerjakan
1. **EditChildScreen** — bikin halaman edit profil: form nama, tanggal lahir, gender (sudah terisi data lama), tombol "Simpan Perubahan" yang manggil `repository.updateChild()`.
2. **Dialog konfirmasi hapus** — saat tekan hapus, munculkan dialog "Hapus [Nama]? Data akan hilang permanen" dengan tombol Batal & Hapus.
3. **Tombol di dashboard** — tambah ikon edit (pensil) dan hapus (sampah) di kartu anak di `ChildListScreen`.
4. **(Opsional) Foto profil** — tombol ganti foto, compress ≤2MB, upload ke Storage `users/{uid}/children/{childId}/profile.jpg`, tampilkan CircleAvatar.

### File yang kamu pegang
- `lib/features/child_profile/presentation/screens/edit_child_screen.dart` (buat baru)
- `lib/features/child_profile/presentation/screens/child_list_screen.dart`

### Deadline
**23 Oktober 2026**

---

# 🎨 NUNES

## TUPOKSI NUNES
Kamu adalah **Frontend (States)**. Kamu ngerjain tampilan **loading, empty, dan error state**. Ini independen — kamu bisa mulai kapan aja tanpa nunggu yang lain.

### Yang harus kamu kerjakan
1. **SkeletonLoader** — bikin widget loading (shimmer / kotak abu-abu animasi) yang tampil pas dashboard lagi nunggu data dari Firestore.
2. **EmptyStateWidget** — tampilan saat belum ada anak: ikon besar + teks "Belum ada data anak" + tombol "Tambah Anak".
3. **ErrorStateWidget** — tampilan saat gagal muat/offline: ikon merah + teks "Gagal memuat data" + tombol "Coba Lagi".
4. **Pasang di ChildListScreen** — pakai `childListAsync.when(loading:, error:, data:)` supaya ketiga state tadi muncul di kondisi yang tepat.
5. **Polish UI** — rapikan spacing (16dp), shadow card, dan scroll supaya konsisten.

### File yang kamu pegang
- `lib/shared/widgets/skeleton_loader.dart` (buat baru)
- `lib/shared/widgets/empty_state_widget.dart` (buat baru)
- `lib/shared/widgets/error_state_widget.dart` (buat baru)
- `lib/features/child_profile/presentation/screens/child_list_screen.dart`

### Deadline
**23 Oktober 2026**

---

# 🔔 RAKA

## TUPOKSI RAKA
Kamu adalah **Frontend (Notifications)**. Kamu bikin **pengingat notifikasi lokal** di HP. Independen — bisa mulai kapan aja.

### Yang harus kamu kerjakan
1. **Tambah dependency** `flutter_local_notifications` di `pubspec.yaml`.
2. **NotificationService** — bikin class untuk `initialize()` (minta izin), `scheduleKpspReminder()`, dan `cancelReminder()`.
3. **Inisialisasi** — panggil `await NotificationService.initialize()` di `main.dart`.
4. **UI toggle pengingat** — tambah `SwitchListTile` di dashboard "Ingatkan Evaluasi KPSP" dan simpan preferensinya pakai SharedPreferences.

### File yang kamu pegang
- `pubspec.yaml`
- `lib/core/services/notification_service.dart` (buat baru)
- `lib/main.dart`
- `lib/features/child_profile/presentation/screens/child_list_screen.dart`

### Deadline
**23 Oktober 2026**

---

# 🧪 HANA

## TUPOKSI HANA
Kamu adalah **QA + Dokumentasi**. Kamu ngetes semua fitur yang udah dibuat temen-temen, laporin bug, dan bikin dokumentasi. Independen — bisa mulai kapan aja.

### Yang harus kamu kerjakan
1. **Testing manual** — coba semua fitur: login/register, tambah/edit/hapus anak, evaluasi KPSP, catat pertumbuhan + foto, notifikasi.
2. **Bug reporting** — bikin issue di GitHub untuk tiap bug, format: `[BUG] judul` + langkah reproduksi + expected vs actual + screenshot.
3. **Fix bug minor** — typo, alignment, warna, validasi yang kurang (misal angka negatif lolos).
4. **README.md** — tulis: deskripsi app, cara setup Firebase, cara run (`flutter run -d chrome`), struktur folder, tech stack, daftar anggota + role.
5. **Edge cases** — cek kondisi offline, foto >2MB, input invalid, dan usia <3 bulan.

### File yang kamu pegang
- `README.md` (buat baru)
- Testing & issue di GitHub

### Deadline
**23 Oktober 2026**

---

## 🚀 Timeline

```
Week 1 (14-18 Okt):
├─ Sakha: Setup Firebase + Auth (14-17) ⚠️ KRITIS

Week 2 (21-25 Okt):
├─ Sakha: ChildRepository (18-20)
├─ Faisal: Milestone + Growth (18-21) — tunggu Sakha
├─ Nopal: Edit/Delete UI (21-23) — tunggu Sakha
├─ Nunes: States (18-23)
├─ Raka: Notifications (18-23)
└─ Hana: QA + Dokumentasi (18-23)

Week 3 (24-28 Okt):
└─ Testing bersama + bug fixes + dokumentasi
```

---

## 📝 Catatan Penting

1. **Jangan merge ke main sebelum review** — tiap PR butuh minimal 1 approval.
2. **Naming** — branch `feat/nama-fitur`, commit `feat: deskripsi` / `fix: deskripsi`.
3. **Sebelum merge** — `flutter analyze` harus lolos, app tidak crash, fitur jalan, data masuk Firebase Console.
4. **Koordinasi**:
   - Sakha → Faisal & Nopal: Auth selesai
   - Sakha → Nopal: ChildRepository selesai
   - Faisal ↔ Sakha: sync Firestore & Storage Rules
5. **Stuck?** Jangan diam — tanya grup, Sakha bantu troubleshoot.

**Deadline Final: 28 Oktober 2026, 23:59**
**Project Manager: Sakha Yusuf Pasha**