import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'a örnek müfredat (Sınıf -> Ders -> Ünite -> Konu) ekler.
///
/// NOT: Kullanıcının isteği gereği bu dosyada **döngü kullanılmadan**
/// (tek tek set çağrılarıyla) seed yapılır. İçerik örnektir; dilediğiniz gibi
/// ders/ünite/konu adlarını değiştirip çoğaltabilirsiniz.
class CurriculumHelper {
  CurriculumHelper._();

  static const String _coursesCollection = 'CurriculumCourses';
  static const String _unitsCollection = 'CurriculumUnits';
  static const String _topicsCollection = 'CurriculumTopics';

  /// Daha önce seed edildiyse tekrar eklemez.
  static Future<void> seedCurriculumIfNeeded() async {
    final firestore = FirebaseFirestore.instance;

    final existing = await firestore
        .collection(_coursesCollection)
        .where('classLevel', isEqualTo: '1. Sınıf')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    // 1-4: Türkçe + Matematik
    await _seedGrade1(firestore);
    await _seedGrade2(firestore);
    await _seedGrade3(firestore);
    await _seedGrade4(firestore);

    // 5-8: Türkçe + Matematik + Fen Bilimleri
    await _seedGrade5(firestore);
    await _seedGrade6(firestore);
    await _seedGrade7(firestore);
    await _seedGrade8(firestore);

    // 9-12: Türk Dili ve Edebiyatı + Matematik + Fizik
    await _seedGrade9(firestore);
    await _seedGrade10(firestore);
    await _seedGrade11(firestore);
    await _seedGrade12(firestore);
  }

  static Future<void> _setCourse(
    FirebaseFirestore firestore, {
    required String courseId,
    required String classLevel,
    required String name,
  }) async {
    await firestore.collection(_coursesCollection).doc(courseId).set({
      'name': name,
      'classLevel': classLevel,
    }, SetOptions(merge: true));
  }

  static Future<void> _setUnit(
    FirebaseFirestore firestore, {
    required String unitId,
    required String courseId,
    required String name,
    required int order,
  }) async {
    await firestore.collection(_unitsCollection).doc(unitId).set({
      'courseId': courseId,
      'name': name,
      'order': order,
    }, SetOptions(merge: true));
  }

  static Future<void> _setTopic(
    FirebaseFirestore firestore, {
    required String topicId,
    required String unitId,
    required String name,
    required int order,
  }) async {
    await firestore.collection(_topicsCollection).doc(topicId).set({
      'unitId': unitId,
      'name': name,
      'order': order,
    }, SetOptions(merge: true));
  }

  // -------------------------
  // 1. SINIF
  // -------------------------
  static Future<void> _seedGrade1(FirebaseFirestore firestore) async {
    const classLevel = '1. Sınıf';

    const cTurkce = 'course_1_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_1_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma Yazmaya Giriş',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_turkce_1_1',
      unitId: uTurkce1,
      name: 'Ses ve harf',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_turkce_1_2',
      unitId: uTurkce1,
      name: 'Hece oluşturma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_turkce_1_3',
      unitId: uTurkce1,
      name: 'Kelime ve cümle',
      order: 2,
    );
    const uTurkce2 = 'unit_1_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Anlama',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_turkce_2_1',
      unitId: uTurkce2,
      name: 'Dinleme',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_turkce_2_2',
      unitId: uTurkce2,
      name: 'Metin anlama',
      order: 1,
    );

    const cMat = 'course_1_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_1_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_matematik_1_1',
      unitId: uMat1,
      name: '1-20 doğal sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_matematik_1_2',
      unitId: uMat1,
      name: 'Toplama',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_matematik_1_3',
      unitId: uMat1,
      name: 'Çıkarma',
      order: 2,
    );
    const uMat2 = 'unit_1_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Geometri ve Ölçme',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_matematik_2_1',
      unitId: uMat2,
      name: 'Temel şekiller',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_1_matematik_2_2',
      unitId: uMat2,
      name: 'Uzunluk ölçme',
      order: 1,
    );
  }

  // -------------------------
  // 2. SINIF
  // -------------------------
  static Future<void> _seedGrade2(FirebaseFirestore firestore) async {
    const classLevel = '2. Sınıf';

    const cTurkce = 'course_2_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_2_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_turkce_1_1',
      unitId: uTurkce1,
      name: 'Akıcı okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_turkce_1_2',
      unitId: uTurkce1,
      name: 'Ana fikir',
      order: 1,
    );
    const uTurkce2 = 'unit_2_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Yazma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_turkce_2_1',
      unitId: uTurkce2,
      name: 'Cümle kurma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_turkce_2_2',
      unitId: uTurkce2,
      name: 'Noktalama',
      order: 1,
    );

    const cMat = 'course_2_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_2_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Sayılar ve İşlemler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_matematik_1_1',
      unitId: uMat1,
      name: '1-100 doğal sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_matematik_1_2',
      unitId: uMat1,
      name: 'Toplama - çıkarma',
      order: 1,
    );
    const uMat2 = 'unit_2_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Geometri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_2_matematik_2_1',
      unitId: uMat2,
      name: 'Şekiller ve örüntüler',
      order: 0,
    );
  }

  // -------------------------
  // 3. SINIF
  // -------------------------
  static Future<void> _seedGrade3(FirebaseFirestore firestore) async {
    const classLevel = '3. Sınıf';

    const cTurkce = 'course_3_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_3_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Anlama',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_turkce_1_1',
      unitId: uTurkce1,
      name: 'Metin türleri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_turkce_1_2',
      unitId: uTurkce1,
      name: 'Kahraman / olay',
      order: 1,
    );
    const uTurkce2 = 'unit_3_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Dil Bilgisi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_turkce_2_1',
      unitId: uTurkce2,
      name: 'İsim',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_turkce_2_2',
      unitId: uTurkce2,
      name: 'Fiil',
      order: 1,
    );

    const cMat = 'course_3_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_3_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_matematik_1_1',
      unitId: uMat1,
      name: 'Çarpma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_matematik_1_2',
      unitId: uMat1,
      name: 'Bölme',
      order: 1,
    );
    const uMat2 = 'unit_3_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Kesirler',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_3_matematik_2_1',
      unitId: uMat2,
      name: 'Basit kesir',
      order: 0,
    );
  }

  // -------------------------
  // 4. SINIF
  // -------------------------
  static Future<void> _seedGrade4(FirebaseFirestore firestore) async {
    const classLevel = '4. Sınıf';

    const cTurkce = 'course_4_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_4_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_turkce_1_1',
      unitId: uTurkce1,
      name: 'Ana fikir',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_turkce_1_2',
      unitId: uTurkce1,
      name: 'Yardımcı fikir',
      order: 1,
    );
    const uTurkce2 = 'unit_4_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Yazma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_turkce_2_1',
      unitId: uTurkce2,
      name: 'Paragraf',
      order: 0,
    );

    const cMat = 'course_4_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_4_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Doğal Sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_matematik_1_1',
      unitId: uMat1,
      name: 'Dört işlem',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_matematik_1_2',
      unitId: uMat1,
      name: 'Problem çözme',
      order: 1,
    );
    const uMat2 = 'unit_4_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Geometri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_4_matematik_2_1',
      unitId: uMat2,
      name: 'Açılar',
      order: 0,
    );
  }

  // -------------------------
  // 5. SINIF
  // -------------------------
  static Future<void> _seedGrade5(FirebaseFirestore firestore) async {
    const classLevel = '5. Sınıf';

    // Türkçe (görsellere göre: SÖZCÜKTE ANLAM → CÜMLEDE ANLAM → PARAGRAF → GÖRSEL YORUMLAMA → DİL YAPILARI → METİN TÜRLERİ → YAZIM KURALLARI)
    const cTurkce5 = 'course_5_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce5,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uT5_1 = 'unit_5_turkce_1';
    await _setUnit(
      firestore,
      unitId: uT5_1,
      courseId: cTurkce5,
      name: 'SÖZCÜKTE ANLAM',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_1',
      unitId: uT5_1,
      name: 'Sözcük Sıralaması',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_2',
      unitId: uT5_1,
      name: 'Yabancı Sözcüklere Türkçe Karşılıklar',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_3',
      unitId: uT5_1,
      name: 'Sözcükte Çok Anlamlılık',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_4',
      unitId: uT5_1,
      name: 'Sözcükte Anlam Özellikleri',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_5',
      unitId: uT5_1,
      name: 'Sözcükte Anlam İlişkileri',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_6',
      unitId: uT5_1,
      name: 'Geçiş ve Bağlantı İfadeleri',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_7',
      unitId: uT5_1,
      name: 'Söz Öbekleri',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_8',
      unitId: uT5_1,
      name: 'Kalıp Sözler - İkileme - Pekiştirme',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_9',
      unitId: uT5_1,
      name: 'Deyimler',
      order: 8,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_1_10',
      unitId: uT5_1,
      name: 'Atasözleri',
      order: 9,
    );
    const uT5_2 = 'unit_5_turkce_2';
    await _setUnit(
      firestore,
      unitId: uT5_2,
      courseId: cTurkce5,
      name: 'CÜMLEDE ANLAM',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_2_1',
      unitId: uT5_2,
      name: 'Anlatımına Göre Cümleler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_2_2',
      unitId: uT5_2,
      name: 'Cümledeki Anlam İlişkileri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_2_3',
      unitId: uT5_2,
      name: 'Cümledeki Duygular ve Kavramlar',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_2_4',
      unitId: uT5_2,
      name: 'Cümle Yorumlama',
      order: 3,
    );
    const uT5_3 = 'unit_5_turkce_3';
    await _setUnit(
      firestore,
      unitId: uT5_3,
      courseId: cTurkce5,
      name: 'PARAGRAF',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_1',
      unitId: uT5_3,
      name: 'Ana Düşünce',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_2',
      unitId: uT5_3,
      name: 'Konu',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_3',
      unitId: uT5_3,
      name: 'Başlık',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_4',
      unitId: uT5_3,
      name: 'Yardımcı Düşünce',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_5',
      unitId: uT5_3,
      name: 'Paragrafta Yapı',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_6',
      unitId: uT5_3,
      name: 'Metin Yapıları',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_7',
      unitId: uT5_3,
      name: 'Düşünceyi Geliştirme Yolları',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_8',
      unitId: uT5_3,
      name: 'Hikâye Unsurları',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_3_9',
      unitId: uT5_3,
      name: 'Metin Karşılaştırma',
      order: 8,
    );
    const uT5_4 = 'unit_5_turkce_4';
    await _setUnit(
      firestore,
      unitId: uT5_4,
      courseId: cTurkce5,
      name: 'GÖRSEL YORUMLAMA VE GRAFİK OKUMA',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_4_1',
      unitId: uT5_4,
      name: 'Görsel Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_4_2',
      unitId: uT5_4,
      name: 'Grafik ve Tablo Okuma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_4_3',
      unitId: uT5_4,
      name: 'Sözel Yetenek',
      order: 2,
    );
    const uT5_5 = 'unit_5_turkce_5';
    await _setUnit(
      firestore,
      unitId: uT5_5,
      courseId: cTurkce5,
      name: 'DİL YAPILARI',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_5_1',
      unitId: uT5_5,
      name: 'İsim ve Fiil',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_5_2',
      unitId: uT5_5,
      name: 'İsimler',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_5_3',
      unitId: uT5_5,
      name: 'İsmi Niteleyen ve Belirten Sözcükler (Sıfatlar)',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_5_4',
      unitId: uT5_5,
      name: 'İsmin Yerini Tutan Sözcükler (Zamirler)',
      order: 3,
    );
    const uT5_6 = 'unit_5_turkce_6';
    await _setUnit(
      firestore,
      unitId: uT5_6,
      courseId: cTurkce5,
      name: 'METİN TÜRLERİ VE SÖZ SANATLARI',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_6_1',
      unitId: uT5_6,
      name: 'Metin Türleri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_6_2',
      unitId: uT5_6,
      name: 'Söz Sanatları',
      order: 1,
    );
    const uT5_7 = 'unit_5_turkce_7';
    await _setUnit(
      firestore,
      unitId: uT5_7,
      courseId: cTurkce5,
      name: 'YAZIM KURALLARI VE NOKTALAMA İŞARETLERİ',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_7_1',
      unitId: uT5_7,
      name: 'Yazım Kuralları',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_turkce_7_2',
      unitId: uT5_7,
      name: 'Noktalama İşaretleri',
      order: 1,
    );

    // Din Kültürü ve Ahlak Bilgisi
    const cDin = 'course_5_din';
    await _setCourse(
      firestore,
      courseId: cDin,
      classLevel: classLevel,
      name: 'Din Kültürü ve Ahlak Bilgisi',
    );
    const uDin1 = 'unit_5_din_1';
    await _setUnit(
      firestore,
      unitId: uDin1,
      courseId: cDin,
      name: "ALLAH İNANCI",
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_1_1',
      unitId: uDin1,
      name: "Evrendeki Düzen, Allah'ın Birliği, İsimleri",
      order: 0,
    );
    const uDin2 = 'unit_5_din_2';
    await _setUnit(
      firestore,
      unitId: uDin2,
      courseId: cDin,
      name: 'BİR SURE',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_2_1',
      unitId: uDin2,
      name: 'İhlas Suresi',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_2_2',
      unitId: uDin2,
      name: 'Kevser Suresi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_2_3',
      unitId: uDin2,
      name: 'Kureyş Suresi',
      order: 2,
    );
    const uDin3 = 'unit_5_din_3';
    await _setUnit(
      firestore,
      unitId: uDin3,
      courseId: cDin,
      name: 'NAMAZ',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_3_1',
      unitId: uDin3,
      name: 'Anlamı, Kılınışı, Kazandırdıkları',
      order: 0,
    );
    const uDin4 = 'unit_5_din_4';
    await _setUnit(
      firestore,
      unitId: uDin4,
      courseId: cDin,
      name: 'BİR DUA',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_4_1',
      unitId: uDin4,
      name: 'Tahiyyat Duası',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_4_2',
      unitId: uDin4,
      name: "Kur'an'ın Düzeni, Özellikleri, Konuları",
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_din_4_3',
      unitId: uDin4,
      name: 'Peygamberler ve Kıssalar',
      order: 2,
    );

    // İngilizce
    const cIng = 'course_5_ingilizce';
    await _setCourse(
      firestore,
      courseId: cIng,
      classLevel: classLevel,
      name: 'İngilizce',
    );
    const uIng1 = 'unit_5_ingilizce_1';
    await _setUnit(
      firestore,
      unitId: uIng1,
      courseId: cIng,
      name: 'UNIT 1',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_1_1',
      unitId: uIng1,
      name: 'Hello!',
      order: 0,
    );
    const uIng2 = 'unit_5_ingilizce_2';
    await _setUnit(
      firestore,
      unitId: uIng2,
      courseId: cIng,
      name: 'UNIT 2',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_2_1',
      unitId: uIng2,
      name: 'My Town',
      order: 0,
    );
    const uIng3 = 'unit_5_ingilizce_3';
    await _setUnit(
      firestore,
      unitId: uIng3,
      courseId: cIng,
      name: 'UNIT 3',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_3_1',
      unitId: uIng3,
      name: 'Games and Hobbies',
      order: 0,
    );
    const uIng4 = 'unit_5_ingilizce_4';
    await _setUnit(
      firestore,
      unitId: uIng4,
      courseId: cIng,
      name: 'UNIT 4',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_4_1',
      unitId: uIng4,
      name: 'My Daily Routine',
      order: 0,
    );
    const uIng5 = 'unit_5_ingilizce_5';
    await _setUnit(
      firestore,
      unitId: uIng5,
      courseId: cIng,
      name: 'UNIT 5',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_5_1',
      unitId: uIng5,
      name: 'Health',
      order: 0,
    );
    const uIng6 = 'unit_5_ingilizce_6';
    await _setUnit(
      firestore,
      unitId: uIng6,
      courseId: cIng,
      name: 'UNIT 6',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_6_1',
      unitId: uIng6,
      name: 'Movies',
      order: 0,
    );
    const uIng7 = 'unit_5_ingilizce_7';
    await _setUnit(
      firestore,
      unitId: uIng7,
      courseId: cIng,
      name: 'UNIT 7',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_7_1',
      unitId: uIng7,
      name: 'Party Time',
      order: 0,
    );
    const uIng8 = 'unit_5_ingilizce_8';
    await _setUnit(
      firestore,
      unitId: uIng8,
      courseId: cIng,
      name: 'UNIT 8',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_8_1',
      unitId: uIng8,
      name: 'Fitness',
      order: 0,
    );
    const uIng9 = 'unit_5_ingilizce_9';
    await _setUnit(
      firestore,
      unitId: uIng9,
      courseId: cIng,
      name: 'UNIT 9',
      order: 8,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_9_1',
      unitId: uIng9,
      name: 'The Animal Shelter',
      order: 0,
    );
    const uIng10 = 'unit_5_ingilizce_10';
    await _setUnit(
      firestore,
      unitId: uIng10,
      courseId: cIng,
      name: 'UNIT 10',
      order: 9,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_ingilizce_10_1',
      unitId: uIng10,
      name: 'Festivals',
      order: 0,
    );

    // Fen Bilimleri
    const cFen = 'course_5_fen';
    await _setCourse(
      firestore,
      courseId: cFen,
      classLevel: classLevel,
      name: 'Fen Bilimleri',
    );
    const uFen1 = 'unit_5_fen_1';
    await _setUnit(
      firestore,
      unitId: uFen1,
      courseId: cFen,
      name: 'GÖKYÜZÜNDEKİ KOMŞULARIMIZ VE BİZ',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_1_1',
      unitId: uFen1,
      name: 'Gökyüzündeki Komşumuz: Güneş',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_1_2',
      unitId: uFen1,
      name: 'Gökyüzündeki Komşumuz: Ay',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_1_3',
      unitId: uFen1,
      name: "Dünya'mız ve Gökyüzündeki Komşularımız",
      order: 2,
    );

    const uFen2 = 'unit_5_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'KUVVETİ TANIYALIM',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_2_1',
      unitId: uFen2,
      name: 'Kuvvet ve Kuvvetin Ölçülmesi',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_2_2',
      unitId: uFen2,
      name: 'Kütle ve Ağırlık İlişkisi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_2_3',
      unitId: uFen2,
      name: 'Sürtünme Kuvveti',
      order: 2,
    );

    const uFen3 = 'unit_5_fen_3';
    await _setUnit(
      firestore,
      unitId: uFen3,
      courseId: cFen,
      name: 'CANLILARIN YAPISINA YOLCULUK',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_3_1',
      unitId: uFen3,
      name: 'Hücre ve Organelleri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_3_2',
      unitId: uFen3,
      name: 'Destek ve Hareket Sistemi',
      order: 1,
    );

    const uFen4 = 'unit_5_fen_4';
    await _setUnit(
      firestore,
      unitId: uFen4,
      courseId: cFen,
      name: 'IŞIĞIN DÜNYASI',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_4_1',
      unitId: uFen4,
      name: 'Işığın Yayılması',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_4_2',
      unitId: uFen4,
      name: 'Işığın Madde ile Etkileşimi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_4_3',
      unitId: uFen4,
      name: 'Tam Gölgenin Oluşumu',
      order: 2,
    );

    const uFen5 = 'unit_5_fen_5';
    await _setUnit(
      firestore,
      unitId: uFen5,
      courseId: cFen,
      name: 'MADDENİN DOĞASI',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_5_1',
      unitId: uFen5,
      name: 'Maddenin Tanecikli Yapısı',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_5_2',
      unitId: uFen5,
      name: 'Isı ve Sıcaklık',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_5_3',
      unitId: uFen5,
      name: 'Maddenin Hâl Değişimi',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_5_4',
      unitId: uFen5,
      name: 'Madde ve Isı',
      order: 3,
    );

    const uFen6 = 'unit_5_fen_6';
    await _setUnit(
      firestore,
      unitId: uFen6,
      courseId: cFen,
      name: 'YAŞAMIMIZDAKİ ELEKTRİK',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_6_1',
      unitId: uFen6,
      name: 'Devre Elemanlarının Sembollerle Gösterimi ve Devre Şemaları',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_6_2',
      unitId: uFen6,
      name:
          'Basit Bir Elektrik Devresinde Ampul Parlaklığını Etkileyen Değişkenler',
      order: 1,
    );

    const uFen7 = 'unit_5_fen_7';
    await _setUnit(
      firestore,
      unitId: uFen7,
      courseId: cFen,
      name: 'SÜRDÜRÜLEBİLİR YAŞAM VE GERİ DÖNÜŞÜM',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_fen_7_1',
      unitId: uFen7,
      name: 'Evsel Atıklar ve Geri Dönüşüm',
      order: 0,
    );

    // Matematik (sıra: mor Matematik görselinden başlayarak 1-GEOMETRİK ŞEKİLLER, 2-SAYILAR 1, 3-GEOMETRİK NİCELİKLER, 4-SAYILAR 2, 5-İSTATİSTİKSEL, 6-CEBİRSEL, 7-VERİDEN OLASILIĞA)
    const cMat = 'course_5_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );

    const uMat1 = 'unit_5_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'GEOMETRİK ŞEKİLLER',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_1',
      unitId: uMat1,
      name: 'Temel Geometrik Çizimlerde Matematiksel Araç ve Teknoloji',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_2',
      unitId: uMat1,
      name: 'Temel Geometrik Çizimlerin İncelenmesi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_3',
      unitId: uMat1,
      name: 'Açıları Ölçmede Matematiksel Araç ve Teknoloji',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_4',
      unitId: uMat1,
      name: 'Düzlemde İki veya Üç Doğrunun Oluşturdukları Açılar',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_5',
      unitId: uMat1,
      name: 'Düzlemde Ardışık Kesişen Doğruların Oluşturduğu Kapalı Şekiller',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_6',
      unitId: uMat1,
      name: 'Çokgenlerin Özellikleri',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_7',
      unitId: uMat1,
      name: 'İki Noktada Kesişen Çember Çiftiyle Oluşan Üçgenler',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_8',
      unitId: uMat1,
      name: 'Çeşitkenar, İkizkenar ve Eşkenar Üçgenlerin Özellikleri',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_9',
      unitId: uMat1,
      name: 'Üçgenlerin Özelliklerini Karşılaştırma',
      order: 8,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_1_10',
      unitId: uMat1,
      name: 'Çemberin Özelliklerini Kullanma',
      order: 9,
    );

    const uMat2 = 'unit_5_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'SAYILAR VE NİCELİKLER - 1',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_1',
      unitId: uMat2,
      name: 'Milyonlar ve Milyarlar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_2',
      unitId: uMat2,
      name: 'Toplama ve Çıkarma İşlemleri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_3',
      unitId: uMat2,
      name: 'Çarpma İşlemi',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_4',
      unitId: uMat2,
      name: 'Bölme İşlemi',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_5',
      unitId: uMat2,
      name: 'Zihinden Toplama ve Çıkarma İşlemleri',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_6',
      unitId: uMat2,
      name: 'Zihinden Çarpma ve Bölme İşlemleri',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_7',
      unitId: uMat2,
      name: 'Toplama ve Çıkarma İşlemlerinde Tahmin Etme',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_8',
      unitId: uMat2,
      name: 'Çarpma ve Bölme İşlemlerinde Tahmin Etme',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_9',
      unitId: uMat2,
      name: 'Bölme İşleminde Kalanı Yorumlama',
      order: 8,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_10',
      unitId: uMat2,
      name: 'Çarpma ve Bölme İşlemlerinde Verilmeyeni Bulma',
      order: 9,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_11',
      unitId: uMat2,
      name: 'Zaman Ölçme',
      order: 10,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_12',
      unitId: uMat2,
      name: 'Problem Çözümünde Kullanılan Stratejiler',
      order: 11,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_2_13',
      unitId: uMat2,
      name: 'Problemler',
      order: 12,
    );

    const uMat3 = 'unit_5_matematik_3';
    await _setUnit(
      firestore,
      unitId: uMat3,
      courseId: cMat,
      name: 'GEOMETRİK NİCELİKLER',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_3_1',
      unitId: uMat3,
      name: 'Aynı Çevre Uzunluğuna Sahip Dikdörtgenler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_3_2',
      unitId: uMat3,
      name: 'Birim Karelerden Alan Hesabı',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_3_3',
      unitId: uMat3,
      name: 'Dikdörtgen Alanı',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_3_4',
      unitId: uMat3,
      name: 'Dikdörtgenin Çevre Uzunluğu ve Alanı İle İlgili Problemler',
      order: 3,
    );

    const uMat4 = 'unit_5_matematik_4';
    await _setUnit(
      firestore,
      unitId: uMat4,
      courseId: cMat,
      name: 'SAYILAR VE NİCELİKLER - 2',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_1',
      unitId: uMat4,
      name: 'Birim Kesirler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_2',
      unitId: uMat4,
      name: 'Tam Sayılı ve Bileşik Kesirler',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_3',
      unitId: uMat4,
      name: 'Denk Kesirler, Sadeleştirme ve Genişletme',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_4',
      unitId: uMat4,
      name: 'Ondalık Gösterim',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_5',
      unitId: uMat4,
      name: 'Kesirden Ondalık Gösterime Çevirme',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_6',
      unitId: uMat4,
      name: 'Yüzdeler',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_7',
      unitId: uMat4,
      name: 'Kesirler ve Ondalık İfadeleri Yüzde İfadeye Çevirme',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_8',
      unitId: uMat4,
      name: 'Kesirlerde Sıralama',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_9',
      unitId: uMat4,
      name: 'Ondalık Gösterimleri Sıralama',
      order: 8,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_4_10',
      unitId: uMat4,
      name: 'Kesirleri, Ondalık Gösterimleri ve Yüzdelik İfadeleri Sıralama',
      order: 9,
    );

    const uMat5 = 'unit_5_matematik_5';
    await _setUnit(
      firestore,
      unitId: uMat5,
      courseId: cMat,
      name: 'İSTATİSTİKSEL ARAŞTIRMA SÜRECİ',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_1',
      unitId: uMat5,
      name: 'Araştırma Soruları',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_2',
      unitId: uMat5,
      name: 'Şekli ve Sıklık Tablosu',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_3',
      unitId: uMat5,
      name: 'Nokta Grafiği',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_4',
      unitId: uMat5,
      name: 'Sütun Grafiği',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_5',
      unitId: uMat5,
      name: 'Daire Grafiği',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_5_6',
      unitId: uMat5,
      name: 'İstatistiksel Araştırma Sürecini Tartışma',
      order: 5,
    );

    const uMat6 = 'unit_5_matematik_6';
    await _setUnit(
      firestore,
      unitId: uMat6,
      courseId: cMat,
      name: 'İŞLEMLERLE CEBİRSEL DÜŞÜNME',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_1',
      unitId: uMat6,
      name: 'Eşitlik Korunumu',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_2',
      unitId: uMat6,
      name: 'İşlem Özellikleri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_3',
      unitId: uMat6,
      name: 'Üslü İfadeler',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_4',
      unitId: uMat6,
      name: 'İşlem Önceliği',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_5',
      unitId: uMat6,
      name: 'Örüntüler',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_6_6',
      unitId: uMat6,
      name: 'Algoritma',
      order: 5,
    );

    const uMat7 = 'unit_5_matematik_7';
    await _setUnit(
      firestore,
      unitId: uMat7,
      courseId: cMat,
      name: 'VERİDEN OLASILIĞA',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_7_1',
      unitId: uMat7,
      name: 'Olasılık Değer Aralığı',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_mat_7_2',
      unitId: uMat7,
      name: 'Olasılık Tahminlerini Değerlendirme',
      order: 1,
    );

    // Sosyal Bilgiler (görsellere göre: BİRLİKTE YAŞAMAK → EVİMİZ DÜNYA → ORTAK MİRASIMIZ → YAŞAYAN DEMOKRASİMİZ → HAYATIMIZDAKİ EKONOMİ → TEKNOLOJİ VE SOSYAL BİLİMLER)
    const cSos = 'course_5_sosyal_bilgiler';
    await _setCourse(
      firestore,
      courseId: cSos,
      classLevel: classLevel,
      name: 'Sosyal Bilgiler',
    );
    const uSos1 = 'unit_5_sosyal_1';
    await _setUnit(
      firestore,
      unitId: uSos1,
      courseId: cSos,
      name: 'BİRLİKTE YAŞAMAK',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_1_1',
      unitId: uSos1,
      name: 'Gruplar ve Roller',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_1_2',
      unitId: uSos1,
      name: 'Kültürel Özelliklere Saygı ve Birlikte Yaşama Kültürü',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_1_3',
      unitId: uSos1,
      name: 'Yardımlaşma ve Dayanışma Faaliyetlerinin Toplumsal Birliğe Etkisi',
      order: 2,
    );
    const uSos2 = 'unit_5_sosyal_2';
    await _setUnit(
      firestore,
      unitId: uSos2,
      courseId: cSos,
      name: 'EVİMİZ DÜNYA',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_2_1',
      unitId: uSos2,
      name: 'Yaşadığımız İlin Göreceli Konumu',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_2_2',
      unitId: uSos2,
      name: 'Yaşadığımız İlde Doğal ve Beşeri Çevredeki Değişim',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_2_3',
      unitId: uSos2,
      name: 'Yaşadığımız İlde Meydana Gelebilecek Afetlerin Etkileri',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_2_4',
      unitId: uSos2,
      name: 'Ülkemize Komşu Devletler',
      order: 3,
    );
    const uSos3 = 'unit_5_sosyal_3';
    await _setUnit(
      firestore,
      unitId: uSos3,
      courseId: cSos,
      name: 'ORTAK MİRASIMIZ',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_3_1',
      unitId: uSos3,
      name: 'Ortak Miras Ögeleri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_3_2',
      unitId: uSos3,
      name: "Anadolu'nun İlk Yerleşim Yerlerinde Yaşam",
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_3_3',
      unitId: uSos3,
      name:
          'Mezopotamya ve Anadolu Medeniyetlerinin Ortak Kültürel Mirasa Katkıları',
      order: 2,
    );
    const uSos4 = 'unit_5_sosyal_4';
    await _setUnit(
      firestore,
      unitId: uSos4,
      courseId: cSos,
      name: 'YAŞAYAN DEMOKRASİMİZ',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_4_1',
      unitId: uSos4,
      name: 'Demokrasi ve Cumhuriyetin Temel Nitelikleri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_4_2',
      unitId: uSos4,
      name: 'Etkin Vatandaşın Özellikleri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_4_3',
      unitId: uSos4,
      name: 'Temel Haklar, Sorumluluklar',
      order: 2,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_4_4',
      unitId: uSos4,
      name: 'Sorunlarımın Çözümünde Başvurabileceğim Kurumlar',
      order: 3,
    );
    const uSos5 = 'unit_5_sosyal_5';
    await _setUnit(
      firestore,
      unitId: uSos5,
      courseId: cSos,
      name: 'HAYATIMIZDAKİ EKONOMİ',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_5_1',
      unitId: uSos5,
      name: 'Kaynakların Verimli Kullanımı',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_5_2',
      unitId: uSos5,
      name: 'Bütçe Oluşturma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_5_3',
      unitId: uSos5,
      name: 'Yaşadığımız İldeki Ekonomik Faaliyetler',
      order: 2,
    );
    const uSos6 = 'unit_5_sosyal_6';
    await _setUnit(
      firestore,
      unitId: uSos6,
      courseId: cSos,
      name: 'TEKNOLOJİ VE SOSYAL BİLİMLER',
      order: 5,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_6_1',
      unitId: uSos6,
      name: 'Teknolojik Gelişmelerin Toplum Hayatına Etkileri',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_5_sosyal_6_2',
      unitId: uSos6,
      name: 'Teknolojik Ürünlerin Bilinçli Kullanımı',
      order: 1,
    );
  }

  // -------------------------
  // 6. SINIF
  // -------------------------
  static Future<void> _seedGrade6(FirebaseFirestore firestore) async {
    const classLevel = '6. Sınıf';

    const cTurkce = 'course_6_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_6_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_turkce_1_1',
      unitId: uTurkce1,
      name: 'Metin türleri',
      order: 0,
    );
    const uTurkce2 = 'unit_6_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Dil Bilgisi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_turkce_2_1',
      unitId: uTurkce2,
      name: 'Fiil kipleri',
      order: 0,
    );

    const cMat = 'course_6_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_6_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Çarpanlar ve Katlar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_matematik_1_1',
      unitId: uMat1,
      name: 'Asal sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_matematik_1_2',
      unitId: uMat1,
      name: 'Bölünebilme',
      order: 1,
    );
    const uMat2 = 'unit_6_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Kesirlerle İşlemler',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_matematik_2_1',
      unitId: uMat2,
      name: 'Toplama-çıkarma',
      order: 0,
    );

    const cFen = 'course_6_fen';
    await _setCourse(
      firestore,
      courseId: cFen,
      classLevel: classLevel,
      name: 'Fen Bilimleri',
    );
    const uFen1 = 'unit_6_fen_1';
    await _setUnit(
      firestore,
      unitId: uFen1,
      courseId: cFen,
      name: 'Madde ve Isı',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_fen_1_1',
      unitId: uFen1,
      name: 'Isı ve sıcaklık',
      order: 0,
    );
    const uFen2 = 'unit_6_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'Kuvvet ve Hareket',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_fen_2_1',
      unitId: uFen2,
      name: 'Sürat',
      order: 0,
    );
  }

  // -------------------------
  // 7. SINIF
  // -------------------------
  static Future<void> _seedGrade7(FirebaseFirestore firestore) async {
    const classLevel = '7. Sınıf';

    const cTurkce = 'course_7_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_7_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_turkce_1_1',
      unitId: uTurkce1,
      name: 'Söz sanatları',
      order: 0,
    );
    const uTurkce2 = 'unit_7_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Yazma',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_turkce_2_1',
      unitId: uTurkce2,
      name: 'Anlatım bozukluğu',
      order: 0,
    );

    const cMat = 'course_7_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_7_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Tam Sayılar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_matematik_1_1',
      unitId: uMat1,
      name: 'İşlemler',
      order: 0,
    );
    const uMat2 = 'unit_7_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Oran-Orantı',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_matematik_2_1',
      unitId: uMat2,
      name: 'Oran',
      order: 0,
    );

    const cFen = 'course_7_fen';
    await _setCourse(
      firestore,
      courseId: cFen,
      classLevel: classLevel,
      name: 'Fen Bilimleri',
    );
    const uFen1 = 'unit_7_fen_1';
    await _setUnit(
      firestore,
      unitId: uFen1,
      courseId: cFen,
      name: 'Hücre ve Bölünmeler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_fen_1_1',
      unitId: uFen1,
      name: 'Mitoz',
      order: 0,
    );
    const uFen2 = 'unit_7_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'Kuvvet ve Enerji',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_fen_2_1',
      unitId: uFen2,
      name: 'Enerji dönüşümleri',
      order: 0,
    );
  }

  // -------------------------
  // 8. SINIF
  // -------------------------
  static Future<void> _seedGrade8(FirebaseFirestore firestore) async {
    const classLevel = '8. Sınıf';

    const cTurkce = 'course_8_turkce';
    await _setCourse(
      firestore,
      courseId: cTurkce,
      classLevel: classLevel,
      name: 'Türkçe',
    );
    const uTurkce1 = 'unit_8_turkce_1';
    await _setUnit(
      firestore,
      unitId: uTurkce1,
      courseId: cTurkce,
      name: 'Okuma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_turkce_1_1',
      unitId: uTurkce1,
      name: 'Paragraf',
      order: 0,
    );
    const uTurkce2 = 'unit_8_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'Dil Bilgisi',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_turkce_2_1',
      unitId: uTurkce2,
      name: 'Cümle türleri',
      order: 0,
    );

    const cMat = 'course_8_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_8_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Cebir',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_matematik_1_1',
      unitId: uMat1,
      name: 'Denklemler',
      order: 0,
    );
    const uMat2 = 'unit_8_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Geometri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_matematik_2_1',
      unitId: uMat2,
      name: 'Üçgenler',
      order: 0,
    );

    const cFen = 'course_8_fen';
    await _setCourse(
      firestore,
      courseId: cFen,
      classLevel: classLevel,
      name: 'Fen Bilimleri',
    );
    const uFen1 = 'unit_8_fen_1';
    await _setUnit(
      firestore,
      unitId: uFen1,
      courseId: cFen,
      name: 'DNA ve Genetik Kod',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_fen_1_1',
      unitId: uFen1,
      name: 'Kalıtım',
      order: 0,
    );
    const uFen2 = 'unit_8_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'Basınç',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_8_fen_2_1',
      unitId: uFen2,
      name: 'Katı basıncı',
      order: 0,
    );
  }

  // -------------------------
  // 9. SINIF
  // -------------------------
  static Future<void> _seedGrade9(FirebaseFirestore firestore) async {
    const classLevel = '9. Sınıf';

    const cTde = 'course_9_tde';
    await _setCourse(
      firestore,
      courseId: cTde,
      classLevel: classLevel,
      name: 'Türk Dili ve Edebiyatı',
    );
    const uTde1 = 'unit_9_tde_1';
    await _setUnit(
      firestore,
      unitId: uTde1,
      courseId: cTde,
      name: 'Şiir',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_tde_1_1',
      unitId: uTde1,
      name: 'Nazım biçimleri',
      order: 0,
    );
    const uTde2 = 'unit_9_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'Öykü',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_tde_2_1',
      unitId: uTde2,
      name: 'Hikâye unsurları',
      order: 0,
    );

    const cMat = 'course_9_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_9_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Kümeler',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_matematik_1_1',
      unitId: uMat1,
      name: 'Küme işlemleri',
      order: 0,
    );
    const uMat2 = 'unit_9_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Denklemler',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_matematik_2_1',
      unitId: uMat2,
      name: 'Birinci derece denklemler',
      order: 0,
    );

    const cFizik = 'course_9_fizik';
    await _setCourse(
      firestore,
      courseId: cFizik,
      classLevel: classLevel,
      name: 'Fizik',
    );
    const uFiz1 = 'unit_9_fizik_1';
    await _setUnit(
      firestore,
      unitId: uFiz1,
      courseId: cFizik,
      name: 'Fizik Bilimine Giriş',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_fizik_1_1',
      unitId: uFiz1,
      name: 'Büyüklükler ve birimler',
      order: 0,
    );
    const uFiz2 = 'unit_9_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'Hareket',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_9_fizik_2_1',
      unitId: uFiz2,
      name: 'Doğrusal hareket',
      order: 0,
    );
  }

  // -------------------------
  // 10. SINIF
  // -------------------------
  static Future<void> _seedGrade10(FirebaseFirestore firestore) async {
    const classLevel = '10. Sınıf';

    const cTde = 'course_10_tde';
    await _setCourse(
      firestore,
      courseId: cTde,
      classLevel: classLevel,
      name: 'Türk Dili ve Edebiyatı',
    );
    const uTde1 = 'unit_10_tde_1';
    await _setUnit(
      firestore,
      unitId: uTde1,
      courseId: cTde,
      name: 'Roman',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_tde_1_1',
      unitId: uTde1,
      name: 'Roman özellikleri',
      order: 0,
    );
    const uTde2 = 'unit_10_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'Tiyatro',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_tde_2_1',
      unitId: uTde2,
      name: 'Tiyatro türleri',
      order: 0,
    );

    const cMat = 'course_10_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_10_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Fonksiyonlar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_matematik_1_1',
      unitId: uMat1,
      name: 'Fonksiyon kavramı',
      order: 0,
    );
    const uMat2 = 'unit_10_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Trigonometri',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_matematik_2_1',
      unitId: uMat2,
      name: 'Trigonometrik oranlar',
      order: 0,
    );

    const cFizik = 'course_10_fizik';
    await _setCourse(
      firestore,
      courseId: cFizik,
      classLevel: classLevel,
      name: 'Fizik',
    );
    const uFiz1 = 'unit_10_fizik_1';
    await _setUnit(
      firestore,
      unitId: uFiz1,
      courseId: cFizik,
      name: 'Kuvvet ve Hareket',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_fizik_1_1',
      unitId: uFiz1,
      name: 'Newton yasaları',
      order: 0,
    );
    const uFiz2 = 'unit_10_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'Elektrik',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_10_fizik_2_1',
      unitId: uFiz2,
      name: 'Elektrik akımı',
      order: 0,
    );
  }

  // -------------------------
  // 11. SINIF
  // -------------------------
  static Future<void> _seedGrade11(FirebaseFirestore firestore) async {
    const classLevel = '11. Sınıf';

    const cTde = 'course_11_tde';
    await _setCourse(
      firestore,
      courseId: cTde,
      classLevel: classLevel,
      name: 'Türk Dili ve Edebiyatı',
    );
    const uTde1 = 'unit_11_tde_1';
    await _setUnit(
      firestore,
      unitId: uTde1,
      courseId: cTde,
      name: 'Deneme',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_tde_1_1',
      unitId: uTde1,
      name: 'Deneme özellikleri',
      order: 0,
    );
    const uTde2 = 'unit_11_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'Sözlü İletişim',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_tde_2_1',
      unitId: uTde2,
      name: 'Sunum',
      order: 0,
    );

    const cMat = 'course_11_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_11_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'Limit',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_matematik_1_1',
      unitId: uMat1,
      name: 'Limit kavramı',
      order: 0,
    );
    const uMat2 = 'unit_11_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Türev',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_matematik_2_1',
      unitId: uMat2,
      name: 'Türev kuralları',
      order: 0,
    );

    const cFizik = 'course_11_fizik';
    await _setCourse(
      firestore,
      courseId: cFizik,
      classLevel: classLevel,
      name: 'Fizik',
    );
    const uFiz1 = 'unit_11_fizik_1';
    await _setUnit(
      firestore,
      unitId: uFiz1,
      courseId: cFizik,
      name: 'Dalgalar',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_fizik_1_1',
      unitId: uFiz1,
      name: 'Ses dalgaları',
      order: 0,
    );
    const uFiz2 = 'unit_11_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'Modern Fizik',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_11_fizik_2_1',
      unitId: uFiz2,
      name: 'Fotoelektrik olay',
      order: 0,
    );
  }

  // -------------------------
  // 12. SINIF
  // -------------------------
  static Future<void> _seedGrade12(FirebaseFirestore firestore) async {
    const classLevel = '12. Sınıf';

    const cTde = 'course_12_tde';
    await _setCourse(
      firestore,
      courseId: cTde,
      classLevel: classLevel,
      name: 'Türk Dili ve Edebiyatı',
    );
    const uTde1 = 'unit_12_tde_1';
    await _setUnit(
      firestore,
      unitId: uTde1,
      courseId: cTde,
      name: 'Şiir',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_tde_1_1',
      unitId: uTde1,
      name: 'Cumhuriyet dönemi şiiri',
      order: 0,
    );
    const uTde2 = 'unit_12_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'Edebiyat Akımları',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_tde_2_1',
      unitId: uTde2,
      name: 'Edebi akımlar',
      order: 0,
    );

    const cMat = 'course_12_matematik';
    await _setCourse(
      firestore,
      courseId: cMat,
      classLevel: classLevel,
      name: 'Matematik',
    );
    const uMat1 = 'unit_12_matematik_1';
    await _setUnit(
      firestore,
      unitId: uMat1,
      courseId: cMat,
      name: 'İntegral',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_matematik_1_1',
      unitId: uMat1,
      name: 'İntegral kavramı',
      order: 0,
    );
    const uMat2 = 'unit_12_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'Olasılık',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_matematik_2_1',
      unitId: uMat2,
      name: 'Koşullu olasılık',
      order: 0,
    );

    const cFizik = 'course_12_fizik';
    await _setCourse(
      firestore,
      courseId: cFizik,
      classLevel: classLevel,
      name: 'Fizik',
    );
    const uFiz1 = 'unit_12_fizik_1';
    await _setUnit(
      firestore,
      unitId: uFiz1,
      courseId: cFizik,
      name: 'Manyetizma',
      order: 0,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_fizik_1_1',
      unitId: uFiz1,
      name: 'Manyetik alan',
      order: 0,
    );
    const uFiz2 = 'unit_12_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'Modern Fizik',
      order: 1,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_12_fizik_2_1',
      unitId: uFiz2,
      name: 'Atom modelleri',
      order: 0,
    );
  }
}
