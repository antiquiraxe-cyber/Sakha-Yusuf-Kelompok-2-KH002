import 'package:langkahawal/features/milestone/domain/entities/milestone_entity.dart';

/// Data soal KPSP berdasarkan Kemenkes.
/// 10 soal per kelompok usia.
/// Sumber: Formulir KPSP Kemenkes RI
class KpspQuestionBank {
  KpspQuestionBank._();

  static List<MilestoneQuestionEntity> getQuestions(int ageMonth) {
    return _allQuestions.where((q) => q.ageMonth == ageMonth).toList();
  }

  static List<int> get availableAges =>
      [3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60];

  /// Cari usia KPSP yang tepat untuk anak.
  /// Standar Kemenkes: misal usia 4 atau 5 bulan -> pakai KPSP 3 bulan.
  static int? getNearestAge(int childAgeMonths) {
    if (childAgeMonths < 3) return null; // Belum waktunya KPSP (KPSP mulai 3 bln)

    int selectedAge = 3;
    for (final age in availableAges) {
      if (childAgeMonths >= age) {
        selectedAge = age;
      } else {
        break;
      }
    }
    return selectedAge;
  }

  static final List<MilestoneQuestionEntity> _allQuestions = [
    // ========================================
    // KPSP 3 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_3_1',
      ageMonth: 3,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Pada waktu bayi telentang, apakah masing-masing lengan dan tungkai bergerak dengan mudah?',
      stimulationTip:
          'Biarkan bayi telentang tanpa bedong agar bisa bergerak bebas.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_2',
      ageMonth: 3,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat mengikuti gerakan Anda dengan menggerakkan kepalanya dari kanan/kiri ke tengah?',
      stimulationTip:
          'Gerakkan benda berwarna cerah perlahan di depan wajah bayi.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_3',
      ageMonth: 3,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat mengikuti gerakan Anda dengan menggerakkan kepalanya dari satu sisi hampir sampai ke sisi yang lain?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_4',
      ageMonth: 3,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Pada waktu bayi telentang, apakah ia melihat dan menatap wajah Anda?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_5',
      ageMonth: 3,
      aspect: MilestoneAspect.social,
      question:
          'Apakah bayi membalas senyum Anda ketika Anda tidak mengajaknya bicara/tersenyum?',
      stimulationTip: 'Sering ajak bayi senyum dan tatap mata.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_6',
      ageMonth: 3,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah bayi mengeluarkan suara-suara seperti berteriak senang atau mengoceh sendiri?',
      stimulationTip:
          'Ajak bicara bayi dengan nada lembut, tirukan suara yang dibuatnya.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_7',
      ageMonth: 3,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Pada waktu bayi telungkup di alas datar, apakah ia bisa mengangkat kepalanya?',
      stimulationTip: 'Latih tummy time 2-3 menit beberapa kali sehari.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_8',
      ageMonth: 3,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Pada waktu bayi telungkup di alas datar, apakah ia dapat mengangkat kepalanya sehingga dagunya terangkat dari alas?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_9',
      ageMonth: 3,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi bisa genggam mainan atau jari Anda dengan erat?',
      stimulationTip:
          'Letakkan jari atau mainan kecil di telapak tangan bayi.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_3_10',
      ageMonth: 3,
      aspect: MilestoneAspect.social,
      question:
          'Pernahkah bayi tersenyum dengan sendirinya tanpa diajak bicara/senyum?',
    ),

    // ========================================
    // KPSP 6 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_6_1',
      ageMonth: 6,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat meraih mainan yang diletakkan agak jauh namun masih dalam jangkauan tangannya?',
      stimulationTip:
          'Letakkan mainan sedikit jauh agar bayi terpancing meraih.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_2',
      ageMonth: 6,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat memegang benda dengan kedua tangan pada saat yang bersamaan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_3',
      ageMonth: 6,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah bayi mengeluarkan suara yang berbunyi seperti "ma ma", "da da", "ba ba"?',
      stimulationTip: 'Ajak bayi bicara dan tirukan suaranya.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_4',
      ageMonth: 6,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Pada waktu bayi telungkup di alas datar, apakah ia dapat mengangkat dada dengan kedua lengannya sebagai penyangga?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_5',
      ageMonth: 6,
      aspect: MilestoneAspect.speech,
      question: 'Apakah bayi menoleh ke arah suara atau sumber bunyi?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_6',
      ageMonth: 6,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah bayi dapat membalik badan dari telentang ke telungkup atau sebaliknya?',
      stimulationTip:
          'Bantu bayi berguling dengan meletakkan mainan di samping.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_7',
      ageMonth: 6,
      aspect: MilestoneAspect.social,
      question: 'Apakah bayi senang bermain ciluk-ba?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_8',
      ageMonth: 6,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah bayi bisa duduk sendiri tanpa bantuan selama beberapa detik?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_9',
      ageMonth: 6,
      aspect: MilestoneAspect.social,
      question:
          'Apakah bayi bisa mengenali wajah orang yang sering ditemui (misalnya tersenyum melihat ibu)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_6_10',
      ageMonth: 6,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat memindahkan benda dari satu tangan ke tangan yang lain?',
    ),

    // ========================================
    // KPSP 9 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_9_1',
      ageMonth: 9,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah bayi meniru kata-kata sederhana seperti "mama", "papa"?',
      stimulationTip:
          'Sering ucapkan "mama", "papa" sambil menunjuk diri sendiri.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_2',
      ageMonth: 9,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah bayi dapat mengambil benda kecil dengan ibu jari dan jari telunjuk (menjimpit)?',
      stimulationTip:
          'Beri potongan makanan kecil yang aman untuk latihan menjimpit.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_3',
      ageMonth: 9,
      aspect: MilestoneAspect.grossMotor,
      question: 'Apakah bayi dapat berdiri sendiri dengan berpegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_4',
      ageMonth: 9,
      aspect: MilestoneAspect.social,
      question: 'Apakah bayi senang bermain tepuk tangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_5',
      ageMonth: 9,
      aspect: MilestoneAspect.grossMotor,
      question: 'Apakah bayi dapat merangkak?',
      stimulationTip: 'Letakkan mainan agak jauh untuk memancing bayi merangkak.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_6',
      ageMonth: 9,
      aspect: MilestoneAspect.social,
      question: 'Apakah bayi menangis/gelisah bila didekati orang asing?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_7',
      ageMonth: 9,
      aspect: MilestoneAspect.fineMotor,
      question: 'Apakah bayi dapat memegang botol minumnya sendiri?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_8',
      ageMonth: 9,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah bayi mengerti perintah sederhana seperti "tidak boleh" atau "dadah"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_9',
      ageMonth: 9,
      aspect: MilestoneAspect.grossMotor,
      question: 'Apakah bayi dapat duduk sendiri tanpa bantuan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_9_10',
      ageMonth: 9,
      aspect: MilestoneAspect.fineMotor,
      question: 'Apakah bayi suka memukul-mukulkan atau membanting mainan?',
    ),

    // ========================================
    // KPSP 12 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_12_1',
      ageMonth: 12,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat mengucapkan 2 kata selain "mama" dan "papa"?',
      stimulationTip:
          'Ajak bicara anak sesering mungkin, sebutkan nama benda di sekitar.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_2',
      ageMonth: 12,
      aspect: MilestoneAspect.fineMotor,
      question: 'Apakah anak bisa memasukkan benda ke dalam wadah?',
      stimulationTip:
          'Beri mainan sortir bentuk atau wadah dan bola kecil.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_3',
      ageMonth: 12,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berdiri sendiri tanpa berpegangan selama beberapa detik?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_4',
      ageMonth: 12,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah anak bisa menjepit benda kecil dengan ibu jari dan jari telunjuk?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_5',
      ageMonth: 12,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat menunjuk apa yang diinginkannya tanpa menangis/merengek?',
      stimulationTip:
          'Ajari anak menunjuk benda sambil menyebutkan namanya.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_6',
      ageMonth: 12,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berjalan dengan berpegangan pada perabot rumah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_7',
      ageMonth: 12,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak mengerti perintah sederhana seperti "ambil itu", "berikan pada mama"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_8',
      ageMonth: 12,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak senang bermain dengan orang lain dan menangis bila permainan dihentikan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_9',
      ageMonth: 12,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat mengangkat badannya ke posisi berdiri tanpa bantuan?',
      stimulationTip:
          'Biarkan anak berlatih berdiri dengan berpegangan kursi atau meja rendah.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_12_10',
      ageMonth: 12,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah anak dapat bertepuk tangan atau melambai-lambai (dadah)?',
    ),

    // ========================================
    // KPSP 15 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_15_1',
      ageMonth: 15,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri 2 kubus, tanpa bantuan, apakah anak dapat mempertemukan dua kubus kecil yang ia pegang?',
      stimulationTip:
          'Latih anak memegang dan memukulkan dua kubus kecil bersamaan.',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_2',
      ageMonth: 15,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah anak dapat mengambil benda kecil seperti kacang atau kismis dengan menggunakan ibu jari dan jari telunjuk (menjimpit)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_3',
      ageMonth: 15,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat jalan sendiri atau jalan dengan berpegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_4',
      ageMonth: 15,
      aspect: MilestoneAspect.social,
      question:
          'Tanpa bantuan, apakah anak dapat bertepuk tangan atau melambai-lambai?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_5',
      ageMonth: 15,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat mengatakan "papa" ketika melihat/memanggil ayahnya, atau "mama" ketika melihat/memanggil ibunya?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_6',
      ageMonth: 15,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat menunjukkan apa yang diinginkannya tanpa menangis atau merengek (menunjuk, menarik, atau mengeluarkan suara menyenangkan)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_7',
      ageMonth: 15,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berdiri sendiri tanpa berpegangan selama kira-kira 5 detik?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_8',
      ageMonth: 15,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berdiri sendiri tanpa berpegangan selama 30 detik atau lebih?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_9',
      ageMonth: 15,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Taruh kubus di lantai, tanpa berpegangan atau menyentuh lantai, apakah anak dapat membungkuk memungut kubus dan kemudian berdiri kembali?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_15_10',
      ageMonth: 15,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berjalan di sepanjang ruangan tanpa jatuh atau terhuyung-huyung?',
    ),

    // ========================================
    // KPSP 18 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_18_1',
      ageMonth: 18,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Letakkan kismis di atas meja dekat anak, apakah anak dapat mengambil dengan ibu jari dan telunjuk?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_2',
      ageMonth: 18,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Gelindingkan bola tenis ke arah anak, apakah anak dapat menggelindingkan atau melempar bola kembali kepada Anda?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_3',
      ageMonth: 18,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat bertepuk tangan atau melambaikan tangan tanpa bantuan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_4',
      ageMonth: 18,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat mengatakan "papa" ketika melihat/memanggil ayahnya atau "mama" ketika melihat/memanggil ibunya?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_5',
      ageMonth: 18,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat menunjukkan apa yang diinginkan tanpa menangis atau merengek?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_6',
      ageMonth: 18,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat minum dari cangkir atau gelas sendiri tanpa tumpah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_7',
      ageMonth: 18,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berdiri kira-kira 5 detik tanpa pegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_8',
      ageMonth: 18,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak dapat berdiri kira-kira lebih dari 30 detik tanpa pegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_9',
      ageMonth: 18,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan kubus di lantai, minta anak memungut, apakah anak dapat memungut dan berdiri kembali tanpa berpegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_18_10',
      ageMonth: 18,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berjalan sepanjang ruangan, dapatkah ia berjalan tanpa terhuyung atau terjatuh?',
    ),

    // ========================================
    // KPSP 21 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_21_1',
      ageMonth: 21,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Letakkan kismis di atas meja dekat anak, apakah anak dapat mengambil dengan ibu jari dan telunjuk?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_2',
      ageMonth: 21,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Gelindingkan bola tenis ke arah anak, apakah anak dapat menggelindingkan atau melempar bola kembali kepada Anda?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_3',
      ageMonth: 21,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Minta anak meletakkan 1 kubus di atas kubus lainnya (1 tingkat saja).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_4',
      ageMonth: 21,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat menunjukkan apa yang diinginkannya tanpa menangis atau merengek?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_5',
      ageMonth: 21,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat minum dari cangkir atau gelas sendiri tanpa tumpah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_6',
      ageMonth: 21,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak suka meniru bila ibu sedang melakukan pekerjaan rumah tangga (menyapu, mencuci, dll)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_7',
      ageMonth: 21,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat mengucapkan minimal 3 kata yang mempunyai arti (selain kata mama dan papa)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_8',
      ageMonth: 21,
      aspect: MilestoneAspect.grossMotor,
      question: 'Apakah anak pernah berjalan mundur minimal 5 langkah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_9',
      ageMonth: 21,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan kubus di lantai, minta anak memungut, apakah anak dapat memungut dan berdiri kembali tanpa berpegangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_21_10',
      ageMonth: 21,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berjalan sepanjang ruangan, dapatkah ia berjalan tanpa terhuyung atau jatuh?',
    ),

    // ========================================
    // KPSP 24 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_24_1',
      ageMonth: 24,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Apakah anak dapat meletakkan satu kubus di atas kubus yang lain tanpa menjatuhkan kubus itu?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_2',
      ageMonth: 24,
      aspect: MilestoneAspect.speech,
      question:
          'Tanpa bimbingan, petunjuk, atau bantuan Anda, dapatkah anak menunjuk dengan benar paling sedikit satu bagian badannya (rambut, mata, hidung, mulut, atau bagian badan yang lain)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_3',
      ageMonth: 24,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak suka meniru bila ibu sedang melakukan pekerjaan rumah tangga (menyapu, mencuci, dll)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_4',
      ageMonth: 24,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat mengucapkan paling sedikit 3 kata yang mempunyai arti selain "papa" dan "mama"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_5',
      ageMonth: 24,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Apakah anak berjalan mundur 5 langkah atau lebih tanpa kehilangan keseimbangan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_6',
      ageMonth: 24,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak melepas pakaiannya seperti baju, rok, atau celananya?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_7',
      ageMonth: 24,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Dapatkah anak berjalan naik tangga sendiri? (Naik tangga dengan posisi tegak atau berpegangan pada dinding/pegangan tangga).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_8',
      ageMonth: 24,
      aspect: MilestoneAspect.social,
      question: 'Dapatkah anak makan nasi sendiri tanpa banyak tumpah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_9',
      ageMonth: 24,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak membantu memungut mainannya sendiri atau membantu mengangkat piring jika diminta?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_24_10',
      ageMonth: 24,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan bola tenis di depan kakinya. Apakah anak dapat menendangnya tanpa berpegangan pada apapun?',
    ),

    // ========================================
    // KPSP 30 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_30_1',
      ageMonth: 30,
      aspect: MilestoneAspect.speech,
      question:
          'Tanpa bimbingan, petunjuk atau bantuan Anda, dapatkah anak menunjuk dengan benar paling sedikit satu bagian badannya (rambut, mata, hidung, mulut, atau bagian badan yang lain)?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_2',
      ageMonth: 30,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Dapatkah anak meletakkan 4 buah kubus satu persatu di atas kubus yang lain tanpa menjatuhkan kubus itu?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_3',
      ageMonth: 30,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat menyebut 2 di antara gambar-gambar ini tanpa bantuan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_4',
      ageMonth: 30,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Bila diberi pensil, apakah anak mencoret-coret kertas tanpa bantuan atau petunjuk?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_5',
      ageMonth: 30,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak melepas pakaiannya seperti baju, rok, atau celananya? (Topi dan kaus kaki tidak ikut dinilai).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_6',
      ageMonth: 30,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Dapatkah anak berjalan naik tangga sendiri? (Posisi tegak atau berpegangan pada dinding/pegangan tangga).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_7',
      ageMonth: 30,
      aspect: MilestoneAspect.social,
      question: 'Dapatkah anak makan nasi sendiri tanpa banyak tumpah?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_8',
      ageMonth: 30,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak membantu memungut mainannya sendiri atau membantu mengangkat piring jika diminta?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_9',
      ageMonth: 30,
      aspect: MilestoneAspect.speech,
      question:
          'Dapatkah anak menggunakan 2 kata pada saat berbicara seperti "minta minum", "mau tidur"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_30_10',
      ageMonth: 30,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan bola tenis di depan kakinya. Dapatkah anak menendang bola kecil ke depan tanpa berpegangan pada apapun?',
    ),

    // ========================================
    // KPSP 36 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_36_1',
      ageMonth: 36,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Dapatkah anak meletakkan 4 buah kubus satu persatu di atas kubus yang lain tanpa menjatuhkan kubus itu?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_2',
      ageMonth: 36,
      aspect: MilestoneAspect.speech,
      question:
          'Apakah anak dapat menyebut 2 di antara gambar-gambar ini tanpa bantuan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_3',
      ageMonth: 36,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Bila diberi pensil, apakah anak mencoret-coret kertas tanpa bantuan atau petunjuk?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_4',
      ageMonth: 36,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Buat garis lurus ke bawah sepanjang sekurang-kurangnya 2,5 cm. Minta anak menggambar garis lain di samping garis ini. Dapatkah anak menggambar garis lurus?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_5',
      ageMonth: 36,
      aspect: MilestoneAspect.speech,
      question:
          'Dapatkah anak menggunakan 2 kata berangkai pada saat berbicara seperti "minta minum", "mau tidur"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_6',
      ageMonth: 36,
      aspect: MilestoneAspect.social,
      question: 'Dapatkah anak mengenakan sepatunya sendiri?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_7',
      ageMonth: 36,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Dapatkah anak mengayuh sepeda roda tiga sejauh sedikitnya 3 meter?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_8',
      ageMonth: 36,
      aspect: MilestoneAspect.speech,
      question:
          'Ikuti perintah ini dengan seksama. Dapatkah anak melaksanakan perintah: "Letakkan kertas ini di lantai", "Letakkan kertas ini di kursi", "Berikan kertas ini kepada ibu"?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_9',
      ageMonth: 36,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan selembar kertas seukuran buku ini di lantai. Apakah anak dapat melompati bagian lebar kertas dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_36_10',
      ageMonth: 36,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Beri bola tenis. Minta anak melemparkan ke arah Anda. Dapatkah anak melempar bola lurus ke arah perut atau dada Anda dari jarak 1,5 meter?',
    ),

    // ========================================
    // KPSP 42 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_42_1',
      ageMonth: 42,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Dapatkah anak meletakkan 8 buah kubus satu persatu di atas yang lain tanpa menjatuhkan kubus tersebut?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_2',
      ageMonth: 42,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri pensil dan kertas. Buatlah lingkaran di atas kertas tersebut. Minta anak menirukan. Dapatkah anak menggambar lingkaran?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_3',
      ageMonth: 42,
      aspect: MilestoneAspect.social,
      question: 'Dapatkah anak mengenakan sepatunya sendiri?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_4',
      ageMonth: 42,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Dapatkah anak mengayuh sepeda roda tiga sejauh sedikitnya 3 meter?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_5',
      ageMonth: 42,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mencuci tangannya sendiri dengan baik setelah makan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_6',
      ageMonth: 42,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mengikuti peraturan permainan bila bermain dengan teman-temannya? (misal: ular tangga, petak umpet, dll).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_7',
      ageMonth: 42,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak mengenakan celana panjang, kemeja, baju, atau kaos kaki tanpa dibantu? (Tidak termasuk memasang kancing atau ikat pinggang).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_8',
      ageMonth: 42,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berdiri satu kaki tanpa berpegangan. Dapatkah ia mempertahankan keseimbangan dalam waktu 2 detik atau lebih?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_42_9',
      ageMonth: 42,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan selembar kertas seukuran buku ini di lantai. Apakah anak dapat melompati panjang kertas ini dengan menangkat kedua kakinya secara bersamaan tanpa didahului lari?',
    ),

    // ========================================
    // KPSP 48 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_48_1',
      ageMonth: 48,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Dapatkah anak meletakkan 8 buah kubus satu persatu di atas yang lain tanpa menjatuhkan kubus tersebut?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_2',
      ageMonth: 48,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri pensil dan kertas. Tanpa membantu anak, minta anak menggambar lingkaran di kertas kosong. Dapatkah anak menggambar lingkaran?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_3',
      ageMonth: 48,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Dapatkah anak mengayuh sepeda roda tiga sejauh sedikitnya 3 meter?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_4',
      ageMonth: 48,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mencuci tangannya sendiri dengan baik setelah makan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_5',
      ageMonth: 48,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mengikuti peraturan permainan bila bermain dengan teman-temannya? (misal: ular tangga, petak umpet, dll).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_6',
      ageMonth: 48,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak mengenakan celana panjang, kemeja, baju, atau kaos kaki tanpa dibantu? (Tidak termasuk memasang kancing, gesper, atau ikat pinggang).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_7',
      ageMonth: 48,
      aspect: MilestoneAspect.speech,
      question:
          'Dapatkah anak menyebut nama lengkapnya tanpa dibantu? (Jawab TIDAK jika ia menyebut sebagian nama atau ucapannya sulit dimengerti).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_8',
      ageMonth: 48,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berdiri satu kaki tanpa berpegangan. Dapatkah ia mempertahankan keseimbangan dalam waktu 2 detik atau lebih?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_9',
      ageMonth: 48,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan selembar kertas seukuran buku ini di lantai. Apakah anak dapat melompati panjang kertas ini dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_48_10',
      ageMonth: 48,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak melempar bola tenis ke arah Anda. Dapatkah anak melempar bola lurus ke arah perut atau dada Anda dari jarak 1,5 meter?',
    ),

    // ========================================
    // KPSP 54 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_54_1',
      ageMonth: 54,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Beri kubus di depannya. Dapatkah anak meletakkan 8 buah kubus satu persatu di atas yang lain tanpa menjatuhkan kubus tersebut?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_2',
      ageMonth: 54,
      aspect: MilestoneAspect.speech,
      question:
          'Tanyakan: "Apa yang kamu lakukan jika kedinginan?" "Jika lapar?" "Jika lelah?" Jawab YA bila anak menjawab ke 3 pertanyaan dengan benar (bukan dengan gerakan atau isyarat).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_3',
      ageMonth: 54,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Perlihatkan gambar kedua garis ini pada anak. Tanyakan: "Mana garis yang lebih panjang?" Apakah anak dapat menunjuk garis yang lebih panjang sebanyak 3 kali dengan benar?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_4',
      ageMonth: 54,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Tanpa membantu anak, minta anak menggambar seperti contoh lingkaran di kertas kosong. Berikan 3 kali kesempatan. Dapatkah anak menggambar lingkaran?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_5',
      ageMonth: 54,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mengikuti peraturan permainan bila bermain dengan teman-temannya? (misal: ular tangga, petak umpet, dll).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_6',
      ageMonth: 54,
      aspect: MilestoneAspect.social,
      question:
          'Dapatkah anak mengenakan celana panjang atau kemeja, baju, atau kaos kaki tanpa dibantu? (Tidak termasuk memasang kancing, gesper, atau ikat pinggang).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_7',
      ageMonth: 54,
      aspect: MilestoneAspect.speech,
      question:
          'Dapatkah anak menyebutkan nama lengkapnya tanpa dibantu? (Jawab TIDAK jika ia hanya menyebut sebagian namanya atau ucapannya sulit dimengerti).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_8',
      ageMonth: 54,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mengancingkan bajunya atau pakaian boneka?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_9',
      ageMonth: 54,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berdiri satu kaki tanpa berpegangan. Dapatkah ia mempertahankan posisinya?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_54_10',
      ageMonth: 54,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Letakkan selembar kertas seukuran buku ini di lantai. Apakah anak dapat melompati panjang kertas ini dengan mengangkat kedua kakinya secara bersamaan tanpa didahului lari?',
    ),

    // ========================================
    // KPSP 60 BULAN
    // ========================================
    const MilestoneQuestionEntity(
      id: 'kpsp_60_1',
      ageMonth: 60,
      aspect: MilestoneAspect.speech,
      question:
          'Tanyakan: "Apa yang kamu lakukan jika kedinginan?" "Jika lapar?" "Jika lelah?" Jawab YA bila anak menjawab ke 3 pertanyaan dengan benar (bukan dengan gerakan atau isyarat).',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_2',
      ageMonth: 60,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Perlihatkan gambar kedua garis ini pada anak. Tanyakan: "Mana garis yang lebih panjang?" Apakah anak dapat menunjuk garis yang lebih panjang sebanyak 3 kali dengan benar?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_3',
      ageMonth: 60,
      aspect: MilestoneAspect.fineMotor,
      question:
          'Tanpa membantu anak dan tanpa memberitahu nama gambar ini, minta anak menggambar seperti contoh lingkaran di kertas kosong. Berikan 3 kali kesempatan. Dapatkah anak menggambar lingkaran?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_4',
      ageMonth: 60,
      aspect: MilestoneAspect.speech,
      question:
          'Katakan pada anak: "Tunjukkan segi empat merah", "Tunjukkan segi empat kuning", "Tunjukkan segi empat biru", "Tunjukkan segi empat hijau". Dapatkah anak menunjuk keempat warna itu dengan benar?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_5',
      ageMonth: 60,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak dapat mengancingkan bajunya atau pakaian boneka?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_6',
      ageMonth: 60,
      aspect: MilestoneAspect.social,
      question:
          'Apakah anak bereaksi dengan tenang dan tidak rewel (tanpa menangis atau menggelayut pada Anda) pada saat Anda meninggalkannya?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_7',
      ageMonth: 60,
      aspect: MilestoneAspect.social,
      question: 'Dapatkah anak sepenuhnya berpakaian sendiri tanpa bantuan?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_8',
      ageMonth: 60,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak berdiri satu kaki tanpa berpegangan. Dapatkah dia mempertahankan keseimbangan dalam waktu 6 detik atau lebih?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_9',
      ageMonth: 60,
      aspect: MilestoneAspect.grossMotor,
      question:
          'Minta anak melompat dengan satu kaki beberapa kali tanpa berpegangan. Apakah ia dapat melompat 2-3 kali dengan satu kaki?',
    ),
    const MilestoneQuestionEntity(
      id: 'kpsp_60_10',
      ageMonth: 60,
      aspect: MilestoneAspect.speech,
      question:
          'Ikuti perintah ini dengan seksama. Jangan memberi isyarat dengan telunjuk atau mata. Dapatkah anak melaksanakan perintah: "Letakkan kertas ini di atas lantai", "Letakkan kertas ini di bawah kursi", "Letakkan kertas ini di depan kamu", "Letakkan kertas ini di belakang kamu"?',
    ),
  ];
}
