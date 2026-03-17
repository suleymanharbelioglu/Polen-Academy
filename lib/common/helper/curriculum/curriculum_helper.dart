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

    // TYT, AYT, YDS (12. sınıf / Mezun için; 11. sınıf için TYT)
    final tytExisting = await firestore
        .collection(_coursesCollection)
        .where('classLevel', isEqualTo: 'TYT')
        .limit(1)
        .get();
    if (tytExisting.docs.isEmpty) {
      await _seedTYT(firestore);
      await _seedAYT(firestore);
      await _seedYDS(firestore);
    }
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

    // Matematik
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
      name: 'Konular',
      order: 0,
    );
    final matTopics = [
      'Geometrik cisimler ve şekiller',
      'Sıvılar',
      'Doğal sayılar',
      'Doğal sayılarda toplama ve çıkarma işlemi',
      'Doğal sayılarda çarpma ve bölme işlemi',
      'Kesirler',
      'Paralarımız',
      'Zaman ölçme',
      'Uzunluk ve kütle ölçme',
      'Uzamsal ilişkiler simetri',
    ];
    for (var i = 0; i < matTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_2_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matTopics[i],
        order: i,
      );
    }

    // Türkçe
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
      name: 'Konular',
      order: 0,
    );
    final turkceTopics = [
      'Harf Bilgisi',
      'Hece Bilgisi',
      'Sözcük Bilgisi',
      'Eş ve Zıt anlamlı sözcükler',
      'Cümle Bilgisi',
      'Neden Sonuç Cümleleri',
      'Karşılaştırma',
      'Benzetme',
      'Örneklendirme',
      'Mi soru ekinin yazımı',
      'Büyük Harflerin Yazımı',
      'Noktalama İşaretleri',
      'Kurallı Kuralsız Cümle',
      'Eş Sesli Sözcükler',
      'Adlar İsimler',
      'Özel Ad Tür Adı',
      'Tekil Çoğul Topluluk Adları',
      'Sıfatlar',
      'Zamirler',
      'Eylemler',
    ];
    for (var i = 0; i < turkceTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_2_turkce_1_${i + 1}',
        unitId: uTurkce1,
        name: turkceTopics[i],
        order: i,
      );
    }

    // Hayat Bilgisi
    const cHayat = 'course_2_hayat_bilgisi';
    await _setCourse(
      firestore,
      courseId: cHayat,
      classLevel: classLevel,
      name: 'Hayat Bilgisi',
    );
    const uHayat1 = 'unit_2_hayat_1';
    await _setUnit(
      firestore,
      unitId: uHayat1,
      courseId: cHayat,
      name: 'Konular',
      order: 0,
    );
    final hayatTopics = [
      'Ben ve Okulum',
      'Sağlığım ve Güvenliğim',
      'Ailem ve Toplum',
      'Yaşadığım yer ve ülkem',
      'Doğa ve çevre',
      'Bilim teknoloji ve sanat',
    ];
    for (var i = 0; i < hayatTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_2_hayat_1_${i + 1}',
        unitId: uHayat1,
        name: hayatTopics[i],
        order: i,
      );
    }

    // İngilizce
    const cIng = 'course_2_ingilizce';
    await _setCourse(
      firestore,
      courseId: cIng,
      classLevel: classLevel,
      name: 'İngilizce',
    );
    const uIng1 = 'unit_2_ingilizce_1';
    await _setUnit(
      firestore,
      unitId: uIng1,
      courseId: cIng,
      name: 'Konular',
      order: 0,
    );
    final ingTopics = [
      'School Life',
      'Classroom Life',
      'Personal Life',
      'Family Life',
      'Homes & Houses & Neighborhoods',
      'Life in the city & The world',
    ];
    for (var i = 0; i < ingTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_2_ingilizce_1_${i + 1}',
        unitId: uIng1,
        name: ingTopics[i],
        order: i,
      );
    }
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

    // Türkçe
    const cTurkce = 'course_4_turkce';
    await _setCourse(firestore, courseId: cTurkce, classLevel: classLevel, name: 'Türkçe');
    const uTurkce1 = 'unit_4_turkce_1';
    await _setUnit(firestore, unitId: uTurkce1, courseId: cTurkce, name: 'Konular', order: 0);
    const turkceTopics = [
      'Harf Bilgisi', 'Alfabetik Sıralama', 'Hece Bilgisi', 'Satır Sonuna Sığmayan Kelimeler',
      'Kitabın Bölümleri', 'Kelime Bilgisi', 'Türkçe\'ye Giren Yabancı Kelimeler', 'Eş Anlamlı Kelimeler',
      'Zıt Anlamlı Kelimeler', 'Eş Sesli Kelimeler', 'Varlıkların Niteliklerini Belirleyen Kelimeler',
      'Cümle Bilgisi', '5N 1K', 'Noktalama İşaretleri', 'Yazım Kuralları', 'Atasözleri ve Deyimler',
      'Metinde Konu ve Ana Fikir', 'Şiir', 'Metni Oluşturan Ögeler', 'Metin Türleri', 'Hikâye Unsurları',
      'Olayların Oluş Sırası', 'Dijital Metinler', 'Mektup ve Davetiye Yazımı', 'Yönerge ve Form Yazma',
      'Gerçek ve Hayal Ürünü Unsurlar', 'Görsel Okuma', 'Grafik ve Harita Okuma',
    ];
    for (var i = 0; i < turkceTopics.length; i++) {
      await _setTopic(firestore, topicId: 'topic_4_turkce_1_${i + 1}', unitId: uTurkce1, name: turkceTopics[i], order: i);
    }

    // Matematik
    const cMat = 'course_4_matematik';
    await _setCourse(firestore, courseId: cMat, classLevel: classLevel, name: 'Matematik');
    const uMat1 = 'unit_4_matematik_1';
    await _setUnit(firestore, unitId: uMat1, courseId: cMat, name: 'Konular', order: 0);
    const matTopics = [
      'Üç Basamaklı Doğal Sayıları Okuyalım ve Yazalım', 'Birer, Onar ve Yüzer Ritmik Sayalım',
      'Basamak Adları ve Basamak Değerleri', 'Sayıları Yuvarlayalım', 'Doğal Sayıları Karşılaştıralım ve Sıralayalım',
      'Ritmik Sayma Yapalım', 'Sayı Örüntüleri', 'Tek ve Çift Doğal Sayılar', 'Romen Rakamları',
      'Toplama İşlemi Yapalım', 'Çıkarma İşlemi Yapalım', 'Toplamı Tahmin Edelim',
      'Zihinden Çıkaralım - Zihinden Toplayalım', 'Verilmeyen Toplananı Bulalım', 'Toplama İşlemi ile Problem Çözelim',
      'Farkı Tahmin Edelim', 'Toplama ve Çıkarma Problemleri', 'Grafik ve Tablo Okuyalım',
      'Grafiklerle İlgili Problem Çözelim', 'Çarpmanın Kat Anlamı', 'Çarpım Tablosu Oluşturalım',
      'Eldesiz ve Eldeli Çarpma İşlemi', '10 ve 100 ile Kısa Yoldan Çarpalım',
      'Azalan ve Artan Çarpanlar Arasındaki İlişki', 'Çarpma Problemleri', 'Bölme İşlemi Yapalım',
      '10\'a Kısa Yoldan Bölelim', 'Bölme İşleminde Terimler Arasındaki İlişkiler', 'Bölme İşlemi Problemleri',
      'Bütün, Yarım, Çeyrek', 'Birim Kesir', 'Pay ve Payda Arasındaki İlişki',
      'Bir Çokluğun Belirtilen Birim Kesir Kadarını Bulalım', 'Payı Paydasından Küçük Kesirler Elde Edelim',
      'Saatler', 'Zaman Ölçüleri Arasındaki İlişki - Olayların Oluş Süresi', 'Zaman Problemleri',
      'Paralarımız - Paralarla İlgili Problemler', 'Tartma Yapalım', 'Tartma Problemleri',
      'Geometrik Cisimler', 'Geometrik Şekiller', 'Geometrik Örüntüler', 'Nokta',
      'Doğru, Işın ve Doğru Parçası', 'Açı', 'Simetri', 'Uzunlukları Ölçelim', 'Uzunluk Problemleri',
      'Çevresini Ölçelim', 'Çevre Problemleri', 'Alan Ölçelim', 'Sıvıları Ölçelim', 'Sıvı Problemleri Çözelim',
    ];
    for (var i = 0; i < matTopics.length; i++) {
      await _setTopic(firestore, topicId: 'topic_4_matematik_1_${i + 1}', unitId: uMat1, name: matTopics[i], order: i);
    }

    // Fen Bilimleri
    const cFen = 'course_4_fen';
    await _setCourse(firestore, courseId: cFen, classLevel: classLevel, name: 'Fen Bilimleri');
    const uFen1 = 'unit_4_fen_1';
    await _setUnit(firestore, unitId: uFen1, courseId: cFen, name: 'Konular', order: 0);
    const fenTopics = [
      'Dünya\'nın Şekli ve Katmanları', 'Dünya\'nın Yapısı', 'Duyu Organlarımız',
      'Varlıkların Hareket Özellikleri', 'Cisimleri Hareket Ettirme ve Durdurma', 'Maddeyi Niteleyen Özellikler',
      'Maddenin Hâlleri', 'Işığın Görmedeki Rolü', 'Işık Kaynakları', 'Çevremizdeki Sesler',
      'Sesin İşitmedeki Rolü', 'Çevremizdeki Varlıkları Tanıyalım', 'Ben ve Çevrem',
      'Elektrikli Araç ve Gereçler', 'Elektrik Kaynakları', 'Elektriğin Güvenli Kullanımı',
    ];
    for (var i = 0; i < fenTopics.length; i++) {
      await _setTopic(firestore, topicId: 'topic_4_fen_1_${i + 1}', unitId: uFen1, name: fenTopics[i], order: i);
    }

    // Hayat Bilgisi (305 → 306 → 307 sırası)
    const cHayat = 'course_4_hayat_bilgisi';
    await _setCourse(firestore, courseId: cHayat, classLevel: classLevel, name: 'Hayat Bilgisi');
    const uHayat1 = 'unit_4_hayat_1';
    await _setUnit(firestore, unitId: uHayat1, courseId: cHayat, name: 'Konular', order: 0);
    const hayatTopics = [
      'Güçlü Yönlerimiz, İlgi Alanlarımız', 'Davranışlarımız Arkadaşlarımızı Nasıl Etkiler',
      'Arkadaşlarımızın Davranışlarının Etkileri', 'Arkadaşlıklarımızı Değerlerimizle Güçlendirelim',
      'Sınıfımızın ve Okulumuzun Krokisini Çizelim', 'Okulumuzun Bize ve Topluma Katkıları',
      'Okulumuzda Sosyal Yardımlaşma ve Dayanışma', 'Okulumuzda Kendimizi Demokratik Yollarla İfade Edelim',
      'Okulumuz Hepimizindir', 'Mesleklerin Yaşamımızdaki Yeri', 'Aile Büyüklerimiz de Çocuktu',
      'Komşuluk İlişkilerimiz', 'Evimizin Bulunduğu Yerin Krokisini Çizelim', 'Evdeki Görev ve Sorumluluklarımız',
      'Evimizdeki Alet ve Teknolojik Ürünler', 'Evimizdeki Kaynakları Verimli ve Etkili Kullanıyoruz',
      'Hayatımızı Planlayalım', 'Aile Bütçemize Katkı Sağlayalım', 'Kişisel Bakım Yaparken Kaynakları Verimli Kullanalım',
      'Bilinçli Tüketici Olalım', 'Mevsimlere Özgü Yiyeceklerle Beslenelim', 'Sağlıklı Beslenelim',
      'Temizlik ve Hijyen Kurallarına Uyalım', 'Trafik İşaret ve Levhalarını Tanıyalım', 'Trafik Kurallarına Uyalım',
      'Çevremizdeki Kazalardan Korunalım', 'Afet ve Acil Durum', 'Güvenliğimiz Tehlikedeyken',
      'Olağanüstü Durumlarda Güvenlik Tedbirleri', 'Oyun Oynarken Güvenliğimize Dikkat Edelim',
      'Yakın Çevremizdeki Yönetim Birimleri', 'Ülkemizin Yönetim Şekli',
      'Çevremizdeki Tarihî, Doğal ve Turistik Yerler', 'Ülkemizi Geliştirelim', 'Mallarımızı Koruyalım',
      'Millî Birlik ve Beraberlik', 'Sosyal Sorumluluk Projelerine Katılalım', 'Atatürk\'ün Kişilik Özellikleri',
      'Ülkemizin Gelişmesine Katkıda Bulunan Kişilere Minnettarız', 'Bitki ve Hayvanların Yaşamımızdaki Önemi',
      'Meyve ve Sebzeler', 'Yönleri Nasıl Buluruz?', 'İnsanların Doğal Unsurlar Üzerindeki Etkileri',
      'Doğa ve Çevremizi Koruyoruz, Geri Dönüşüme Katkı Sağlıyoruz',
    ];
    for (var i = 0; i < hayatTopics.length; i++) {
      await _setTopic(firestore, topicId: 'topic_4_hayat_1_${i + 1}', unitId: uHayat1, name: hayatTopics[i], order: i);
    }

    // İngilizce
    const cIng = 'course_4_ingilizce';
    await _setCourse(firestore, courseId: cIng, classLevel: classLevel, name: 'İngilizce');
    const uIng1 = 'unit_4_ingilizce_1';
    await _setUnit(firestore, unitId: uIng1, courseId: cIng, name: 'Konular', order: 0);
    const ingTopics = [
      'Greetings', 'My Family', 'People I Love', 'Feelings', 'Toys and Games', 'My house',
      'My City', 'Transportation', 'Weather', 'Nature',
    ];
    for (var i = 0; i < ingTopics.length; i++) {
      await _setTopic(firestore, topicId: 'topic_4_ingilizce_1_${i + 1}', unitId: uIng1, name: ingTopics[i], order: i);
    }
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

    // Türkçe
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
      name: 'SÖZCÜKTE ANLAM',
      order: 0,
    );
    final turkceUnit1Topics = [
      'Yabancı Sözcüklere Türkçe Karşılıklar',
      'Sözcükte Anlam Özellikleri',
      'Sözcükler Arası Anlam İlişkileri',
      'Geçiş ve Bağlantı İfadeleri',
      'Söz Öbekleri',
      'Kalıp Sözler, İkileme, Pekiştirme',
      'Atasözleri',
      'Deyimler',
    ];
    for (var i = 0; i < turkceUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_1_${i + 1}',
        unitId: uTurkce1,
        name: turkceUnit1Topics[i],
        order: i,
      );
    }

    const uTurkce2 = 'unit_6_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'CÜMLEDE ANLAM',
      order: 1,
    );
    final turkceUnit2Topics = [
      'Anlatımına Göre Cümleler',
      'Cümlede Anlam İlişkileri',
      'Cümlede Kavramlar ve Duygular',
      'Gerçek ve Hayal Ürünü İfadeler',
      'Cümle Yorumlama',
    ];
    for (var i = 0; i < turkceUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_2_${i + 1}',
        unitId: uTurkce2,
        name: turkceUnit2Topics[i],
        order: i,
      );
    }

    const uTurkce3 = 'unit_6_turkce_3';
    await _setUnit(
      firestore,
      unitId: uTurkce3,
      courseId: cTurkce,
      name: 'PARAGRAF',
      order: 2,
    );
    final turkceUnit3Topics = [
      'Ana Fikir',
      'Konu-Başlık',
      'Yardımcı Düşünce',
      'Paragrafta Yapı',
      'Metin Yapıları',
      'Düşünceyi Geliştirme Yolları',
      'Metin Karşılaştırma',
      'Anlatıcı Türleri/Hikaye Unsuru',
      'Paragraf Türü',
    ];
    for (var i = 0; i < turkceUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_3_${i + 1}',
        unitId: uTurkce3,
        name: turkceUnit3Topics[i],
        order: i,
      );
    }

    const uTurkce4 = 'unit_6_turkce_4';
    await _setUnit(
      firestore,
      unitId: uTurkce4,
      courseId: cTurkce,
      name: 'GÖRSEL, GRAFİK VE TABLO YORUMLAMA',
      order: 3,
    );
    final turkceUnit4Topics = [
      'Görsel Yorumlama',
      'Grafik ve Tablo Okuma',
    ];
    for (var i = 0; i < turkceUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_4_${i + 1}',
        unitId: uTurkce4,
        name: turkceUnit4Topics[i],
        order: i,
      );
    }

    const uTurkce5 = 'unit_6_turkce_5';
    await _setUnit(
      firestore,
      unitId: uTurkce5,
      courseId: cTurkce,
      name: 'AKIL YÜRÜTME VE SÖZEL YETENEK',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_turkce_5_1',
      unitId: uTurkce5,
      name: 'Akıl Yürütme ve Sözel Yetenek',
      order: 0,
    );

    const uTurkce6 = 'unit_6_turkce_6';
    await _setUnit(
      firestore,
      unitId: uTurkce6,
      courseId: cTurkce,
      name: 'DİL YAPILARI',
      order: 5,
    );
    final turkceUnit6Topics = [
      'Kök ve Ek',
      'Yapım Ekleri',
      'Yardımcı Unsüzler',
      'Ses Olayları',
      'Özne-Yüklem Uyumu',
    ];
    for (var i = 0; i < turkceUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_6_${i + 1}',
        unitId: uTurkce6,
        name: turkceUnit6Topics[i],
        order: i,
      );
    }

    const uTurkce7 = 'unit_6_turkce_7';
    await _setUnit(
      firestore,
      unitId: uTurkce7,
      courseId: cTurkce,
      name: 'METİN TÜRLERİ VE SÖZ SANATLARI',
      order: 6,
    );
    final turkceUnit7Topics = [
      'Öyküleyici Metin Türleri',
      'Bilgilendirici Metin Türleri',
      'Söz Sanatları',
    ];
    for (var i = 0; i < turkceUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_7_${i + 1}',
        unitId: uTurkce7,
        name: turkceUnit7Topics[i],
        order: i,
      );
    }

    const uTurkce8 = 'unit_6_turkce_8';
    await _setUnit(
      firestore,
      unitId: uTurkce8,
      courseId: cTurkce,
      name: 'YAZIM KURALLARI VE NOKTALAMA İŞARETLERİ',
      order: 7,
    );
    final turkceUnit8Topics = [
      'Büyük Harflerin Yazımı',
      'Sayıların Yazımı',
      'Eklerin Yazımı',
      'Kısaltmaların Yazımı',
      'Noktalama İşaretleri',
    ];
    for (var i = 0; i < turkceUnit8Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_turkce_8_${i + 1}',
        unitId: uTurkce8,
        name: turkceUnit8Topics[i],
        order: i,
      );
    }

    // Matematik
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
      name: 'SAYILAR VE NİCELİKLER - 1',
      order: 0,
    );
    final matUnit1Topics = [
      'Çarpanlar',
      'Katlar',
      'Kalansız Bölünebilme',
      'Asal Sayılar ve Doğal Sayıları Asal Çarpanlarına Ayırma',
      'Ortak Kat ve Ortak Bölen',
    ];
    for (var i = 0; i < matUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matUnit1Topics[i],
        order: i,
      );
    }

    const uMat2 = 'unit_6_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'İSTATİSTİKSEL ARAŞTIRMA SÜRECİ',
      order: 1,
    );
    final matUnit2Topics = [
      'Veri Çeşitleri-Araştırma Sorusu Oluşturma',
      'Araştırma Sorusu Kriterleri - Kök Diyagramı',
      'Aritmetik Ortalama - Ortanca - Tepe Değer - Açıklık',
      'Sonuçları Yorumlama',
      'Sonuç veya Yorumları Tartışma',
    ];
    for (var i = 0; i < matUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_2_${i + 1}',
        unitId: uMat2,
        name: matUnit2Topics[i],
        order: i,
      );
    }

    const uMat3 = 'unit_6_matematik_3';
    await _setUnit(
      firestore,
      unitId: uMat3,
      courseId: cMat,
      name: 'SAYILAR VE NİCELİKLER - 2',
      order: 2,
    );
    final matUnit3Topics = [
      'Kesir-Bölme İlişkisi',
      'Ondalık Gösterim Çözümleme',
      'Ondalık Gösterimleri Yuvarlama',
      'Ondalık Gösterimleri Karşılaştırma',
      'Devirli Ondalık Gösterim',
      'Uzunluk Ölçüleri',
      'Kesir Problemleri',
      'Ondalık Gösterim Problemleri',
      'Yüzde Problemleri',
    ];
    for (var i = 0; i < matUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_3_${i + 1}',
        unitId: uMat3,
        name: matUnit3Topics[i],
        order: i,
      );
    }

    const uMat4 = 'unit_6_matematik_4';
    await _setUnit(
      firestore,
      unitId: uMat4,
      courseId: cMat,
      name: 'VERİDEN OLASILIĞA',
      order: 3,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_matematik_4_1',
      unitId: uMat4,
      name: 'Bir Olayın Olasılığını Gözleme Dayalı Tahmin Etme',
      order: 0,
    );

    const uMat5 = 'unit_6_matematik_5';
    await _setUnit(
      firestore,
      unitId: uMat5,
      courseId: cMat,
      name: 'GEOMETRİK ŞEKİLLER',
      order: 4,
    );
    final matUnit5Topics = [
      'Yöndeş, İç Ters ve Dış Ters Açılar',
      'İki Paralel Doğru ve İki Kesenin Oluşturduğu Çokgenler',
      'Dörtgenlerin Özellikleri',
      'Gerçek Yaşam Problemleri',
    ];
    for (var i = 0; i < matUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_5_${i + 1}',
        unitId: uMat5,
        name: matUnit5Topics[i],
        order: i,
      );
    }

    const uMat6 = 'unit_6_matematik_6';
    await _setUnit(
      firestore,
      unitId: uMat6,
      courseId: cMat,
      name: 'İŞLEMLERLE CEBİRSEL DÜŞÜNME VE DEĞİŞİM',
      order: 5,
    );
    final matUnit6Topics = [
      'Cebirsel İfadeler',
      'Cebirsel İfadeleri Genelleme',
      'Cebirsel İfadelerin Farklı Gösterimi',
      'Cebirsel İfadelerin Değerini Hesaplama',
      'Örüntüler',
      'Cebirsel İfadeler ve Algoritma',
    ];
    for (var i = 0; i < matUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_6_${i + 1}',
        unitId: uMat6,
        name: matUnit6Topics[i],
        order: i,
      );
    }

    const uMat7 = 'unit_6_matematik_7';
    await _setUnit(
      firestore,
      unitId: uMat7,
      courseId: cMat,
      name: 'GEOMETRİK NİCELİKLER',
      order: 6,
    );
    final matUnit7Topics = [
      'Alan Ölçü Birimlerinin Birbirine Dönüştürülmesi',
      'Üçgenin Alanı',
      'Paralelkenarın Alanı',
      'Alan Problemleri',
      'Çember Uzunluğu',
      'Çember Problemleri',
      'Çemberde Merkez Açı ve Gördüğü Yay',
    ];
    for (var i = 0; i < matUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_matematik_7_${i + 1}',
        unitId: uMat7,
        name: matUnit7Topics[i],
        order: i,
      );
    }

    // Fen Bilimleri
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
      name: 'GÜNEŞ SİSTEMİ VE TUTULMALAR',
      order: 0,
    );
    final fenUnit1Topics = [
      'Güneş Sistemi',
      'Güneş ve Ay Tutulmaları',
    ];
    for (var i = 0; i < fenUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_1_${i + 1}',
        unitId: uFen1,
        name: fenUnit1Topics[i],
        order: i,
      );
    }

    const uFen2 = 'unit_6_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'KUVVETİN ETKİSİNDE HAREKET',
      order: 1,
    );
    final fenUnit2Topics = [
      'Bileşke Kuvvet',
      'Sabit Süratli ve Sabit Hızlı Hareket',
    ];
    for (var i = 0; i < fenUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_2_${i + 1}',
        unitId: uFen2,
        name: fenUnit2Topics[i],
        order: i,
      );
    }

    const uFen3 = 'unit_6_fen_3';
    await _setUnit(
      firestore,
      unitId: uFen3,
      courseId: cFen,
      name: 'CANLILARDA SİSTEMLER',
      order: 2,
    );
    final fenUnit3Topics = [
      'Eşeyli ve Eşeysiz Üreme',
      'Bitkilerde Üreme Büyüme ve Gelişme',
      'Tohumun Çimlenmesine Etki Eden Faktörler',
      'Hayvanlarda Üreme Büyüme ve Gelişme',
      'İnsanda Üremeyi Sağlayan Yapı ve Organlar',
      'Sinir Sistemi',
      'İç Salgı Bezlerinin Vücut İçin Önemi',
      'Çocuktan Ergenliğe Geçiş',
      'Denetleyici Düzenleyici Sistemlerin Sağlığı',
    ];
    for (var i = 0; i < fenUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_3_${i + 1}',
        unitId: uFen3,
        name: fenUnit3Topics[i],
        order: i,
      );
    }

    const uFen4 = 'unit_6_fen_4';
    await _setUnit(
      firestore,
      unitId: uFen4,
      courseId: cFen,
      name: 'IŞIĞIN YANSIMASI VE RENKLER',
      order: 3,
    );
    final fenUnit4Topics = [
      'Işığın Yansıması',
      'Aynalar',
      'Işığın Soğurulması',
    ];
    for (var i = 0; i < fenUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_4_${i + 1}',
        unitId: uFen4,
        name: fenUnit4Topics[i],
        order: i,
      );
    }

    const uFen5 = 'unit_6_fen_5';
    await _setUnit(
      firestore,
      unitId: uFen5,
      courseId: cFen,
      name: 'MADDENİN AYIRT EDİCİ ÖZELLİKLERİ',
      order: 4,
    );
    final fenUnit5Topics = [
      'Genleşme ve Büzülme',
      'Maddenin Hal Değişim Noktaları',
      'Yoğunluk',
    ];
    for (var i = 0; i < fenUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_5_${i + 1}',
        unitId: uFen5,
        name: fenUnit5Topics[i],
        order: i,
      );
    }

    const uFen6 = 'unit_6_fen_6';
    await _setUnit(
      firestore,
      unitId: uFen6,
      courseId: cFen,
      name: 'ELEKTRİĞİN İLETİMİ VE DİRENÇ',
      order: 5,
    );
    final fenUnit6Topics = [
      'Elektriğin İletimi',
      'Elektriksel Direnç ve Bağlı Olduğu Faktörler',
    ];
    for (var i = 0; i < fenUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_6_${i + 1}',
        unitId: uFen6,
        name: fenUnit6Topics[i],
        order: i,
      );
    }

    const uFen7 = 'unit_6_fen_7';
    await _setUnit(
      firestore,
      unitId: uFen7,
      courseId: cFen,
      name: 'SÜRDÜRÜLEBİLİR YAŞAM VE ETKİLEŞİM',
      order: 6,
    );
    final fenUnit7Topics = [
      'Biyoçeşitlilik',
      'Isı Amaçlı Yakıt Kullanımı',
      'İnsan ve Çevre Etkileşimi',
    ];
    for (var i = 0; i < fenUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_fen_7_${i + 1}',
        unitId: uFen7,
        name: fenUnit7Topics[i],
        order: i,
      );
    }

    // İngilizce
    const cIng = 'course_6_ingilizce';
    await _setCourse(
      firestore,
      courseId: cIng,
      classLevel: classLevel,
      name: 'İngilizce',
    );
    final ingUnits = [
      ('UNIT 1', 'Life'),
      ('UNIT 2', 'Yummy Breakfast'),
      ('UNIT 3', 'Downtown'),
      ('UNIT 4', 'Weather and Emotions'),
      ('UNIT 5', 'At The Fair'),
      ('UNIT 6', 'Occupations'),
      ('UNIT 7', 'Holidays'),
      ('UNIT 8', 'Bookworms'),
      ('UNIT 9', 'Saving the Planet'),
      ('UNIT 10', 'Democracy'),
    ];
    for (var i = 0; i < ingUnits.length; i++) {
      final unitId = 'unit_6_ingilizce_${i + 1}';
      await _setUnit(
        firestore,
        unitId: unitId,
        courseId: cIng,
        name: ingUnits[i].$1,
        order: i,
      );
      await _setTopic(
        firestore,
        topicId: 'topic_6_ingilizce_${i + 1}_1',
        unitId: unitId,
        name: ingUnits[i].$2,
        order: 0,
      );
    }

    // Sosyal Bilgiler
    const cSos = 'course_6_sosyal';
    await _setCourse(
      firestore,
      courseId: cSos,
      classLevel: classLevel,
      name: 'Sosyal Bilgiler',
    );
    const uSos1 = 'unit_6_sosyal_1';
    await _setUnit(
      firestore,
      unitId: uSos1,
      courseId: cSos,
      name: 'BİRLİKTE YAŞAMAK',
      order: 0,
    );
    final sosyalUnit1Topics = [
      'Zaman İçinde Değişen Gruplar ve Roller',
      'Kültürel Bağlarımızın ve Milli Değerlerimizin Toplumsal Birlikteliğe Etkisi',
      'Toplumsal Sorunlar ve Çözüm Önerileri',
    ];
    for (var i = 0; i < sosyalUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_1_${i + 1}',
        unitId: uSos1,
        name: sosyalUnit1Topics[i],
        order: i,
      );
    }

    const uSos2 = 'unit_6_sosyal_2';
    await _setUnit(
      firestore,
      unitId: uSos2,
      courseId: cSos,
      name: 'EVİMİZ DÜNYA',
      order: 1,
    );
    final sosyalUnit2Topics = [
      'Ülkemizin, Kıtaların ve Okyanusların Konum Özellikleri',
      'Doğal ve Beşeri Çevre Özellikleri Arasındaki İlişki',
      'Ülkemizin Türk Dünyasıyla Kültürel İş Birlikleri',
    ];
    for (var i = 0; i < sosyalUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_2_${i + 1}',
        unitId: uSos2,
        name: sosyalUnit2Topics[i],
        order: i,
      );
    }

    const uSos3 = 'unit_6_sosyal_3';
    await _setUnit(
      firestore,
      unitId: uSos3,
      courseId: cSos,
      name: 'ORTAK MİRASIMIZ',
      order: 2,
    );
    final sosyalUnit3Topics = [
      'Türkistan\'da Kurulan İlk Türk Devletlerinin Medeniyetimize Katkıları',
      'VII.-XIII. Yüzyıllar Arasında İslam Medeniyetinin İnsanlığın Ortak Mirasına Katkıları',
      'Ortak Mirasına Katkılar',
      'İslamiyet\'in Kabulüyle Türklerde Meydana Gelen Değişimler',
      'XI.-XIII. Yüzyıllar Arasında Anadolu\'nun Türkleşmesi ve İslamlaşması',
    ];
    for (var i = 0; i < sosyalUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_3_${i + 1}',
        unitId: uSos3,
        name: sosyalUnit3Topics[i],
        order: i,
      );
    }

    const uSos4 = 'unit_6_sosyal_4';
    await _setUnit(
      firestore,
      unitId: uSos4,
      courseId: cSos,
      name: 'YAŞAYAN DEMOKRASİMİZ',
      order: 3,
    );
    final sosyalUnit4Topics = [
      'Yönetimin Karar Alma Sürecini Etkileyen Unsurlar',
      'Temel Hak ve Sorumlulukların Toplumsal Düzenin Sürdürülmesindeki Önemi',
      'Dijitalleşme ve Teknolojik Gelişmelerin Vatandaşlık Hak ve Sorumluluklarına Etkileri',
    ];
    for (var i = 0; i < sosyalUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_4_${i + 1}',
        unitId: uSos4,
        name: sosyalUnit4Topics[i],
        order: i,
      );
    }

    const uSos5 = 'unit_6_sosyal_5';
    await _setUnit(
      firestore,
      unitId: uSos5,
      courseId: cSos,
      name: 'HAYATIMIZDAKİ EKONOMİ',
      order: 4,
    );
    final sosyalUnit5Topics = [
      'Ülkemizin Kaynakları ve Ekonomik Faaliyetler',
      'Ekonomik Faaliyetler ve Meslekler',
      'Yatırım ve Pazarlama Süreci',
    ];
    for (var i = 0; i < sosyalUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_5_${i + 1}',
        unitId: uSos5,
        name: sosyalUnit5Topics[i],
        order: i,
      );
    }

    const uSos6 = 'unit_6_sosyal_6';
    await _setUnit(
      firestore,
      unitId: uSos6,
      courseId: cSos,
      name: 'TEKNOLOJİ VE SOSYAL BİLİMLER',
      order: 5,
    );
    final sosyalUnit6Topics = [
      'Ulaşım ve İletişim Teknolojilerinin Kültürel Etkileşimdeki Rolü',
      'Telif ve Patent Süreci',
    ];
    for (var i = 0; i < sosyalUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_sosyal_6_${i + 1}',
        unitId: uSos6,
        name: sosyalUnit6Topics[i],
        order: i,
      );
    }

    // Din Kültürü ve Ahlak Bilgisi
    const cDin = 'course_6_din';
    await _setCourse(
      firestore,
      courseId: cDin,
      classLevel: classLevel,
      name: 'Din Kültürü ve Ahlak Bilgisi',
    );
    const uDin1 = 'unit_6_din_1';
    await _setUnit(
      firestore,
      unitId: uDin1,
      courseId: cDin,
      name: 'PEYGAMBER VE İLAHİ KİTAP İNANCI',
      order: 0,
    );
    final dinUnit1Topics = [
      'Peygamberler ve Vahiy (Maarif Model)',
      'İlahi Kitaplar ve Felak Suresi (Maarif Model)',
    ];
    for (var i = 0; i < dinUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_din_1_${i + 1}',
        unitId: uDin1,
        name: dinUnit1Topics[i],
        order: i,
      );
    }

    const uDin2 = 'unit_6_din_2';
    await _setUnit(
      firestore,
      unitId: uDin2,
      courseId: cDin,
      name: 'RAMAZAN VE ORUÇ',
      order: 1,
    );
    final dinUnit2Topics = [
      'Oruç İbadeti (Maarif Model)',
      'İftar Duası (Maarif Model)',
    ];
    for (var i = 0; i < dinUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_din_2_${i + 1}',
        unitId: uDin2,
        name: dinUnit2Topics[i],
        order: i,
      );
    }

    const uDin3 = 'unit_6_din_3';
    await _setUnit(
      firestore,
      unitId: uDin3,
      courseId: cDin,
      name: 'AHLAKİ DAVRANIŞLAR',
      order: 2,
    );
    final dinUnit3Topics = [
      'Ahlaki Davranışlar ve Vatan Sevgisi (Maarif Model)',
      'Kunut Duaları (Maarif Model)',
    ];
    for (var i = 0; i < dinUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_din_3_${i + 1}',
        unitId: uDin3,
        name: dinUnit3Topics[i],
        order: i,
      );
    }

    const uDin4 = 'unit_6_din_4';
    await _setUnit(
      firestore,
      unitId: uDin4,
      courseId: cDin,
      name: 'PEYGAMBERLİĞİNDEN ÖNCE HZ. MUHAMMED',
      order: 3,
    );
    final dinUnit4Topics = [
      'Hz. Muhammed\'in (sav) Peygamberliğinden Önceki Hayatı',
      'Fil Suresi (Maarif Model)',
    ];
    for (var i = 0; i < dinUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_6_din_4_${i + 1}',
        unitId: uDin4,
        name: dinUnit4Topics[i],
        order: i,
      );
    }

    const uDin5 = 'unit_6_din_5';
    await _setUnit(
      firestore,
      unitId: uDin5,
      courseId: cDin,
      name: 'KÜLTÜRÜMÜZDEKİ DİNİ MOTİFLER',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_6_din_5_1',
      unitId: uDin5,
      name: 'Geleneklerimizde, Edebiyatımızda ve Sanatımızda Dini Motifler',
      order: 0,
    );
  }

  // -------------------------
  // 7. SINIF
  // -------------------------
  static Future<void> _seedGrade7(FirebaseFirestore firestore) async {
    const classLevel = '7. Sınıf';

    // Türkçe
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
      name: 'SÖZCÜKTE ANLAM',
      order: 0,
    );
    final turkceUnit1Topics = [
      'Sözcükte Anlam Özellikleri',
      'Sözcükler Arası Anlam İlişkileri',
      'Söz Öbekleri',
      'Deyimler',
      'Atasözleri',
    ];
    for (var i = 0; i < turkceUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_1_${i + 1}',
        unitId: uTurkce1,
        name: turkceUnit1Topics[i],
        order: i,
      );
    }

    const uTurkce2 = 'unit_7_turkce_2';
    await _setUnit(
      firestore,
      unitId: uTurkce2,
      courseId: cTurkce,
      name: 'CÜMLEDE ANLAM',
      order: 1,
    );
    final turkceUnit2Topics = [
      'Anlatımına Göre Cümleler',
      'Cümlede Anlam İlişkileri',
      'Cümlede Kavramlar ve Duygular',
      'Cümle Yorumlama, Yakın Anlamlı Cümleler',
    ];
    for (var i = 0; i < turkceUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_2_${i + 1}',
        unitId: uTurkce2,
        name: turkceUnit2Topics[i],
        order: i,
      );
    }

    const uTurkce3 = 'unit_7_turkce_3';
    await _setUnit(
      firestore,
      unitId: uTurkce3,
      courseId: cTurkce,
      name: 'PARAGRAF',
      order: 2,
    );
    final turkceUnit3Topics = [
      'Ana Fikir',
      'Konu-Başlık',
      'Yardımcı Düşünce',
      'Paragrafta Yapı',
      'Metin Karşılaştırma',
      'Anlatım Biçimleri',
      'Düşünceyi Geliştirme Yolları',
      'Anlatıcı Türü',
    ];
    for (var i = 0; i < turkceUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_3_${i + 1}',
        unitId: uTurkce3,
        name: turkceUnit3Topics[i],
        order: i,
      );
    }

    const uTurkce4 = 'unit_7_turkce_4';
    await _setUnit(
      firestore,
      unitId: uTurkce4,
      courseId: cTurkce,
      name: 'GÖRSEL, GRAFİK VE TABLO YORUMLAMA',
      order: 3,
    );
    final turkceUnit4Topics = [
      'Görsel Okuma',
      'Görsel Yorumlama',
      'Grafik ve Tablo Okuma',
      'Görsel Düşünme',
    ];
    for (var i = 0; i < turkceUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_4_${i + 1}',
        unitId: uTurkce4,
        name: turkceUnit4Topics[i],
        order: i,
      );
    }

    const uTurkce5 = 'unit_7_turkce_5';
    await _setUnit(
      firestore,
      unitId: uTurkce5,
      courseId: cTurkce,
      name: 'SÖZEL YETENEK VE AKIL YÜRÜTME',
      order: 4,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_turkce_5_1',
      unitId: uTurkce5,
      name: 'Mantık / Muhakeme',
      order: 0,
    );

    const uTurkce6 = 'unit_7_turkce_6';
    await _setUnit(
      firestore,
      unitId: uTurkce6,
      courseId: cTurkce,
      name: 'FİİLLER',
      order: 5,
    );
    final turkceUnit6Topics = [
      'İş - Oluş - Durum Fiilleri',
      'Fiil Çekimi',
      'Fiillerde Anlam (Zaman) Kayması',
      'Fiilde Yapı',
      'Ek Fiil - Fiillerde Zaman',
      'Ek Fiil - Bileşik Zamanlı Fiil',
    ];
    for (var i = 0; i < turkceUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_6_${i + 1}',
        unitId: uTurkce6,
        name: turkceUnit6Topics[i],
        order: i,
      );
    }

    const uTurkce7 = 'unit_7_turkce_7';
    await _setUnit(
      firestore,
      unitId: uTurkce7,
      courseId: cTurkce,
      name: 'ZARF (BELİRTEÇ)',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_turkce_7_1',
      unitId: uTurkce7,
      name: 'Zarf',
      order: 0,
    );

    const uTurkce8 = 'unit_7_turkce_8';
    await _setUnit(
      firestore,
      unitId: uTurkce8,
      courseId: cTurkce,
      name: 'ANLATIM BOZUKLUĞU',
      order: 7,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_turkce_8_1',
      unitId: uTurkce8,
      name: 'Anlama Dayalı Bozukluklar',
      order: 0,
    );

    const uTurkce9 = 'unit_7_turkce_9';
    await _setUnit(
      firestore,
      unitId: uTurkce9,
      courseId: cTurkce,
      name: 'METİN TÜRLERİ VE SÖZ SANATLARI',
      order: 8,
    );
    final turkceUnit9Topics = [
      'Metin Türleri',
      'Söz Sanatları',
    ];
    for (var i = 0; i < turkceUnit9Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_9_${i + 1}',
        unitId: uTurkce9,
        name: turkceUnit9Topics[i],
        order: i,
      );
    }

    const uTurkce10 = 'unit_7_turkce_10';
    await _setUnit(
      firestore,
      unitId: uTurkce10,
      courseId: cTurkce,
      name: 'YAZIM KURALLARI VE NOKTALAMA İŞARETLERİ',
      order: 9,
    );
    final turkceUnit10Topics = [
      'Yazım Kuralları',
      'Noktalama İşaretleri',
    ];
    for (var i = 0; i < turkceUnit10Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_turkce_10_${i + 1}',
        unitId: uTurkce10,
        name: turkceUnit10Topics[i],
        order: i,
      );
    }

    // Matematik
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
      name: 'TAM SAYILARLA İŞLEMLER',
      order: 0,
    );
    final matUnit1Topics = [
      'Tam Sayılarla Toplama ve Çıkarma İşlemi',
      'Toplama İşleminin Özellikleri',
      'Tam Sayılarla Çarpma ve Bölme İşlemi',
      'Üslü İfadeler',
      'Tam Sayı Problemleri',
    ];
    for (var i = 0; i < matUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matUnit1Topics[i],
        order: i,
      );
    }

    const uMat2 = 'unit_7_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'RASYONEL SAYILAR',
      order: 1,
    );
    final matUnit2Topics = [
      'Rasyonel Sayıları Sayı Doğrusunda Gösterme',
      'Rasyonel Sayıların Ondalık Gösterimi',
      'Devirli Olan ve Olmayan Gösterimden Rasyonel Sayıya',
      'Rasyonel Sayıları Karşılaştırma ve Sıralama',
    ];
    for (var i = 0; i < matUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_2_${i + 1}',
        unitId: uMat2,
        name: matUnit2Topics[i],
        order: i,
      );
    }

    const uMat3 = 'unit_7_matematik_3';
    await _setUnit(
      firestore,
      unitId: uMat3,
      courseId: cMat,
      name: 'RASYONEL SAYILARLA İŞLEMLER',
      order: 2,
    );
    final matUnit3Topics = [
      'Toplama ve Çıkarma İşlemi',
      'Çarpma ve Bölme İşlemi',
      'Çok Adımlı İşlemler',
      'Rasyonel Sayıların Karesi ve Küpü',
      'Rasyonel Sayı Problemleri',
    ];
    for (var i = 0; i < matUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_3_${i + 1}',
        unitId: uMat3,
        name: matUnit3Topics[i],
        order: i,
      );
    }

    const uMat4 = 'unit_7_matematik_4';
    await _setUnit(
      firestore,
      unitId: uMat4,
      courseId: cMat,
      name: 'CEBİRSEL İFADELER',
      order: 3,
    );
    final matUnit4Topics = [
      'Toplama ve Çıkarma İşlemi',
      'Bir Doğal Sayı ile Cebirsel İfadeyi Çarpma',
      'Sayı Örüntüleri ve Kuralları',
    ];
    for (var i = 0; i < matUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_4_${i + 1}',
        unitId: uMat4,
        name: matUnit4Topics[i],
        order: i,
      );
    }

    const uMat5 = 'unit_7_matematik_5';
    await _setUnit(
      firestore,
      unitId: uMat5,
      courseId: cMat,
      name: 'EŞİTLİK VE DENKLEM',
      order: 4,
    );
    final matUnit5Topics = [
      'Eşitliğin Korunumu',
      'Denklem Kurma',
      'Denklem Çözme',
      'Denklem Problemleri',
    ];
    for (var i = 0; i < matUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_5_${i + 1}',
        unitId: uMat5,
        name: matUnit5Topics[i],
        order: i,
      );
    }

    const uMat6 = 'unit_7_matematik_6';
    await _setUnit(
      firestore,
      unitId: uMat6,
      courseId: cMat,
      name: 'ORAN VE ORANTI',
      order: 5,
    );
    final matUnit6Topics = [
      'Çokluklardan Biri 1 iken Diğerini Bulma',
      'Orantılı Çoklukları Bulma',
      'Çokluklardan Orantılı Olduğuna Karar Verme',
      'Doğru Orantılı Çokluklar',
      'Doğru Orantıda Orantı Sabiti',
      'Ters Orantılı Çokluklar',
      'Orantı Problemleri',
    ];
    for (var i = 0; i < matUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_6_${i + 1}',
        unitId: uMat6,
        name: matUnit6Topics[i],
        order: i,
      );
    }

    const uMat7 = 'unit_7_matematik_7';
    await _setUnit(
      firestore,
      unitId: uMat7,
      courseId: cMat,
      name: 'YÜZDELER',
      order: 6,
    );
    final matUnit7Topics = [
      'Bir Çokluğun Yüzdesini ve Yüzdesi Verilen Çokluğu Belirlemek',
      'Bir Çokluğu Diğer Çokluğun Yüzdesi Olarak Belirleme',
      'Çokluğu Bir Yüzde Kadar Artırma veya Azaltma',
      'Yüzde Problemleri',
    ];
    for (var i = 0; i < matUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_7_${i + 1}',
        unitId: uMat7,
        name: matUnit7Topics[i],
        order: i,
      );
    }

    const uMat8 = 'unit_7_matematik_8';
    await _setUnit(
      firestore,
      unitId: uMat8,
      courseId: cMat,
      name: 'DOĞRULAR VE AÇILAR',
      order: 7,
    );
    final matUnit8Topics = [
      'Açıortay',
      'Yöndeş, Ters, İç Ters, Dış Ters, Eş ve Bütünler Açılar',
    ];
    for (var i = 0; i < matUnit8Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_8_${i + 1}',
        unitId: uMat8,
        name: matUnit8Topics[i],
        order: i,
      );
    }

    const uMat9 = 'unit_7_matematik_9';
    await _setUnit(
      firestore,
      unitId: uMat9,
      courseId: cMat,
      name: 'ÇOKGENLER',
      order: 8,
    );
    final matUnit9Topics = [
      'Düzgün Çokgenlerde Kenar ve Açı',
      'Çokgenlerde Köşegen, İç ve Dış Açı Özellikleri',
      'Dikdörtgen, Paralelkenar, Yamuk ve Eşkenar Dörtgen',
      'Eşkenar Dörtgen ve Yamuğun Alanı',
      'Alan Problemleri',
    ];
    for (var i = 0; i < matUnit9Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_9_${i + 1}',
        unitId: uMat9,
        name: matUnit9Topics[i],
        order: i,
      );
    }

    const uMat10 = 'unit_7_matematik_10';
    await _setUnit(
      firestore,
      unitId: uMat10,
      courseId: cMat,
      name: 'ÇEMBER VE DAİRE',
      order: 9,
    );
    final matUnit10Topics = [
      'Merkez Açı ve Gördüğü Yay',
      'Çemberin ve Parçasının Uzunluğu',
      'Dairenin ve Diliminin Alanı',
    ];
    for (var i = 0; i < matUnit10Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_10_${i + 1}',
        unitId: uMat10,
        name: matUnit10Topics[i],
        order: i,
      );
    }

    const uMat11 = 'unit_7_matematik_11';
    await _setUnit(
      firestore,
      unitId: uMat11,
      courseId: cMat,
      name: 'VERİ ANALİZİ',
      order: 10,
    );
    final matUnit11Topics = [
      'Çizgi Grafiği Oluşturma ve Yorumlama',
      'Ortalama, Ortanca ve Tepe Değer',
      'Daire Grafiği Oluşturma ve Yorumlama',
      'Grafikler Arasındaki Dönüşümler',
    ];
    for (var i = 0; i < matUnit11Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_11_${i + 1}',
        unitId: uMat11,
        name: matUnit11Topics[i],
        order: i,
      );
    }

    const uMat12 = 'unit_7_matematik_12';
    await _setUnit(
      firestore,
      unitId: uMat12,
      courseId: cMat,
      name: 'CİSİMLERİN FARKLI YÖNDEN GÖRÜNÜMLERİ',
      order: 11,
    );
    final matUnit12Topics = [
      'Cisimlerin Farklı Yönden Görünümlerini Çizme',
      'Görünümü Verilen Yapıları Oluşturma',
    ];
    for (var i = 0; i < matUnit12Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_matematik_12_${i + 1}',
        unitId: uMat12,
        name: matUnit12Topics[i],
        order: i,
      );
    }

    // Fen Bilimleri
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
      name: 'GÜNEŞ SİSTEMİ VE ÖTESİ',
      order: 0,
    );
    final fenUnit1Topics = [
      'Uzay Araştırmaları',
      'Güneş Sistemi Ötesi, Gök Cisimleri',
    ];
    for (var i = 0; i < fenUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_1_${i + 1}',
        unitId: uFen1,
        name: fenUnit1Topics[i],
        order: i,
      );
    }

    const uFen2 = 'unit_7_fen_2';
    await _setUnit(
      firestore,
      unitId: uFen2,
      courseId: cFen,
      name: 'HÜCRE VE BÖLÜNMELER',
      order: 1,
    );
    final fenUnit2Topics = [
      'Hücre',
      'Mitoz',
      'Mayoz',
    ];
    for (var i = 0; i < fenUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_2_${i + 1}',
        unitId: uFen2,
        name: fenUnit2Topics[i],
        order: i,
      );
    }

    const uFen3 = 'unit_7_fen_3';
    await _setUnit(
      firestore,
      unitId: uFen3,
      courseId: cFen,
      name: 'KUVVET VE ENERJİ',
      order: 2,
    );
    final fenUnit3Topics = [
      'Kütle ve Ağırlık İlişkisi',
      'Kuvvet, İş ve Enerji İlişkisi',
      'Kinetik Enerji',
      'Potansiyel Enerji',
      'Enerji Dönüşümleri',
    ];
    for (var i = 0; i < fenUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_3_${i + 1}',
        unitId: uFen3,
        name: fenUnit3Topics[i],
        order: i,
      );
    }

    const uFen4 = 'unit_7_fen_4';
    await _setUnit(
      firestore,
      unitId: uFen4,
      courseId: cFen,
      name: 'SAF MADDE VE KARIŞIMLAR',
      order: 3,
    );
    final fenUnit4Topics = [
      'Maddenin Tanecikli Yapısı',
      'Saf Maddeler',
      'Karışımlar',
      'Karışımların Ayrılması',
      'Evsel Atıklar ve Geri Dönüşüm',
    ];
    for (var i = 0; i < fenUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_4_${i + 1}',
        unitId: uFen4,
        name: fenUnit4Topics[i],
        order: i,
      );
    }

    const uFen5 = 'unit_7_fen_5';
    await _setUnit(
      firestore,
      unitId: uFen5,
      courseId: cFen,
      name: 'IŞIĞIN MADDE İLE ETKİLEŞİMİ',
      order: 4,
    );
    final fenUnit5Topics = [
      'Işığın Soğurulması',
      'Çizgilerin Renkli Görünmesi',
      'Aynalar',
      'Işığın Kırılması ve Mercekler',
    ];
    for (var i = 0; i < fenUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_5_${i + 1}',
        unitId: uFen5,
        name: fenUnit5Topics[i],
        order: i,
      );
    }

    const uFen6 = 'unit_7_fen_6';
    await _setUnit(
      firestore,
      unitId: uFen6,
      courseId: cFen,
      name: 'CANLILARDA ÜREME, BÜYÜME VE GELİŞME',
      order: 5,
    );
    final fenUnit6Topics = [
      'İnsanda Üreme, Büyüme ve Gelişme',
      'Eşeyli ve Eşeysiz Üreme',
      'Bitkilerde Üreme, Büyüme ve Gelişme',
      'Hayvanlarda Üreme, Büyüme ve Gelişme',
    ];
    for (var i = 0; i < fenUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_fen_6_${i + 1}',
        unitId: uFen6,
        name: fenUnit6Topics[i],
        order: i,
      );
    }

    const uFen7 = 'unit_7_fen_7';
    await _setUnit(
      firestore,
      unitId: uFen7,
      courseId: cFen,
      name: 'ELEKTRİK DEVRELERİ',
      order: 6,
    );
    await _setTopic(
      firestore,
      topicId: 'topic_7_fen_7_1',
      unitId: uFen7,
      name: 'Ampullerin Bağlanma Şekilleri',
      order: 0,
    );

    // İngilizce
    const cIng = 'course_7_ingilizce';
    await _setCourse(
      firestore,
      courseId: cIng,
      classLevel: classLevel,
      name: 'İngilizce',
    );
    final ingUnits = [
      ('SPORTS', 'Sports'),
      ('APPEARANCE AND PERSONALITY', 'Appearance and Personality'),
      ('BIOGRAPHIES', 'Biographies'),
      ('WILD ANIMALS', 'Wild Animals'),
      ('TELEVISION', 'Television'),
      ('CELEBRATIONS', 'Celebrations'),
      ('DREAMS', 'Dreams'),
      ('PUBLIC BUILDINGS', 'Public Buildings'),
      ('ENVIRONMENT', 'Environment'),
      ('PLANETS', 'Planets'),
    ];
    for (var i = 0; i < ingUnits.length; i++) {
      final unitId = 'unit_7_ingilizce_${i + 1}';
      await _setUnit(
        firestore,
        unitId: unitId,
        courseId: cIng,
        name: ingUnits[i].$1,
        order: i,
      );
      await _setTopic(
        firestore,
        topicId: 'topic_7_ingilizce_${i + 1}_1',
        unitId: unitId,
        name: ingUnits[i].$2,
        order: 0,
      );
    }

    // Sosyal Bilgiler
    const cSos = 'course_7_sosyal';
    await _setCourse(
      firestore,
      courseId: cSos,
      classLevel: classLevel,
      name: 'Sosyal Bilgiler',
    );
    const uSos1 = 'unit_7_sosyal_1';
    await _setUnit(
      firestore,
      unitId: uSos1,
      courseId: cSos,
      name: 'BİREY VE TOPLUM',
      order: 0,
    );
    final sosyalUnit1Topics = [
      'İletişim Benimle Başlar',
      'Çevremle İletişim Kurabiliyorum',
      'İletişim Araçları',
      'İletişim Özgürlüğü',
    ];
    for (var i = 0; i < sosyalUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_1_${i + 1}',
        unitId: uSos1,
        name: sosyalUnit1Topics[i],
        order: i,
      );
    }

    const uSos2 = 'unit_7_sosyal_2';
    await _setUnit(
      firestore,
      unitId: uSos2,
      courseId: cSos,
      name: 'KÜLTÜR VE MİRAS',
      order: 1,
    );
    final sosyalUnit2Topics = [
      'Bir Devlet Doğuyor',
      'Osmanlı Fetih Siyaseti',
      'Avrupa Gelişiyor, Osmanlı ve Diğer Devletler Etkileniyor',
      'Islahatlarla Değişen Osmanlı Kurumları',
      'Osmanlıdan Kalan Mirasımız',
    ];
    for (var i = 0; i < sosyalUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_2_${i + 1}',
        unitId: uSos2,
        name: sosyalUnit2Topics[i],
        order: i,
      );
    }

    const uSos3 = 'unit_7_sosyal_3';
    await _setUnit(
      firestore,
      unitId: uSos3,
      courseId: cSos,
      name: 'İNSANLAR, YERLER VE ÇEVRELER',
      order: 2,
    );
    final sosyalUnit3Topics = [
      'Geçmişten Günümüze Yerleşme',
      'Türkiye Nüfusunun Özellikleri',
      'Türkiye\'de Göçün Neden ve Sonuçları',
      'Yerleşme ve Seyahat Özgürlüğümü Kullanıyorum',
    ];
    for (var i = 0; i < sosyalUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_3_${i + 1}',
        unitId: uSos3,
        name: sosyalUnit3Topics[i],
        order: i,
      );
    }

    const uSos4 = 'unit_7_sosyal_4';
    await _setUnit(
      firestore,
      unitId: uSos4,
      courseId: cSos,
      name: 'BİLİM, TEKNOLOJİ VE TOPLUM',
      order: 3,
    );
    final sosyalUnit4Topics = [
      'Geçmişten Günümüze Bilginin Serüveni',
      'Bilimin Öncüleri',
      'Karanlıktan Aydınlığa',
      'Özgür Düşünce ve Bilim',
    ];
    for (var i = 0; i < sosyalUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_4_${i + 1}',
        unitId: uSos4,
        name: sosyalUnit4Topics[i],
        order: i,
      );
    }

    const uSos5 = 'unit_7_sosyal_5';
    await _setUnit(
      firestore,
      unitId: uSos5,
      courseId: cSos,
      name: 'ÜRETİM, DAĞITIM VE TÜKETİM',
      order: 4,
    );
    final sosyalUnit5Topics = [
      'Üretim ve Yönetimin Temeli Toprak',
      'Üretim Yolculuğu',
      'Vakıf Demek Medeniyet Demek',
      'İçin Ehli İnsan Yetiştirmek',
      'Hayalimdeki Meslek',
      'Dijital Teknoloji',
    ];
    for (var i = 0; i < sosyalUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_5_${i + 1}',
        unitId: uSos5,
        name: sosyalUnit5Topics[i],
        order: i,
      );
    }

    const uSos6 = 'unit_7_sosyal_6';
    await _setUnit(
      firestore,
      unitId: uSos6,
      courseId: cSos,
      name: 'ETKİN VATANDAŞLIK',
      order: 5,
    );
    final sosyalUnit6Topics = [
      'Demokrasinin Tarihçeki Yolculuğu',
      'Atatürk ve Demokrasi',
      'Türkiye Cumhuriyetinin Temel Nitelikleri',
      'Huzur Demokrasi ile Gelir',
    ];
    for (var i = 0; i < sosyalUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_6_${i + 1}',
        unitId: uSos6,
        name: sosyalUnit6Topics[i],
        order: i,
      );
    }

    const uSos7 = 'unit_7_sosyal_7';
    await _setUnit(
      firestore,
      unitId: uSos7,
      courseId: cSos,
      name: 'KÜRESEL BAĞLANTILAR',
      order: 6,
    );
    final sosyalUnit7Topics = [
      'Türkiye ve Dünya',
      'Gelişen Türkiye',
      'Yanlış Bildiğimiz Doğrular',
      'Günümüz Dünya Sorunlarına Çözümler',
    ];
    for (var i = 0; i < sosyalUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_sosyal_7_${i + 1}',
        unitId: uSos7,
        name: sosyalUnit7Topics[i],
        order: i,
      );
    }

    // Din Kültürü ve Ahlak Bilgisi
    const cDin = 'course_7_din';
    await _setCourse(
      firestore,
      courseId: cDin,
      classLevel: classLevel,
      name: 'Din Kültürü ve Ahlak Bilgisi',
    );
    const uDin1 = 'unit_7_din_1';
    await _setUnit(
      firestore,
      unitId: uDin1,
      courseId: cDin,
      name: 'MELEK VE AHİRET İNANCI',
      order: 0,
    );
    final dinUnit1Topics = [
      'Görünen, görünmeyen varlıklar ve melekler',
      'Dünya ve ahiret hayatı - Ahiret hayatının aşamaları',
      'Ahiret inancının insan davranışlarına etkisi',
      'Bir peygamber tanıyorum: Hz. İsa',
      'Nas suresi ve anlamı',
    ];
    for (var i = 0; i < dinUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_din_1_${i + 1}',
        unitId: uDin1,
        name: dinUnit1Topics[i],
        order: i,
      );
    }

    const uDin2 = 'unit_7_din_2';
    await _setUnit(
      firestore,
      unitId: uDin2,
      courseId: cDin,
      name: 'HAC VE KURBAN',
      order: 1,
    );
    final dinUnit2Topics = [
      'İslam\'da hac ibadeti ve önemi',
      'Umre ve önemi',
      'Kurban ibadeti ve önemi',
      'Hz. İsmail - En\'am suresi',
    ];
    for (var i = 0; i < dinUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_din_2_${i + 1}',
        unitId: uDin2,
        name: dinUnit2Topics[i],
        order: i,
      );
    }

    const uDin3 = 'unit_7_din_3';
    await _setUnit(
      firestore,
      unitId: uDin3,
      courseId: cDin,
      name: 'AHLAKİ DAVRANIŞLAR',
      order: 2,
    );
    final dinUnit3Topics = [
      'Güzel ahlaki tutum ve davranışlar',
      'Bir peygamber tanıyorum: Hz. Salih',
      'Felak suresi ve anlamı',
    ];
    for (var i = 0; i < dinUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_din_3_${i + 1}',
        unitId: uDin3,
        name: dinUnit3Topics[i],
        order: i,
      );
    }

    const uDin4 = 'unit_7_din_4';
    await _setUnit(
      firestore,
      unitId: uDin4,
      courseId: cDin,
      name: 'ALLAH\'IN KULU VE ELÇİSİ: HZ. MUHAMMED',
      order: 3,
    );
    final dinUnit4Topics = [
      'Allah\'ın kulu ve elçisi: Hz. Muhammed',
      'Kafirun suresi ve anlamı',
    ];
    for (var i = 0; i < dinUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_din_4_${i + 1}',
        unitId: uDin4,
        name: dinUnit4Topics[i],
        order: i,
      );
    }

    const uDin5 = 'unit_7_din_5';
    await _setUnit(
      firestore,
      unitId: uDin5,
      courseId: cDin,
      name: 'İSLAM DÜŞÜNCESİNDE YORUMLAR',
      order: 4,
    );
    final dinUnit5Topics = [
      'Din anlayışındaki yorum farklılıklarının sebepleri',
      'İslam düşüncesinde yorum biçimleri',
      'İslam düşüncesinde tasavvufi yorumlar',
    ];
    for (var i = 0; i < dinUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_7_din_5_${i + 1}',
        unitId: uDin5,
        name: dinUnit5Topics[i],
        order: i,
      );
    }
  }

  // -------------------------
  // 8. SINIF
  // -------------------------
  static Future<void> _seedGrade8(FirebaseFirestore firestore) async {
    const classLevel = '8. Sınıf';

    // Türkçe
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
      name: 'Konular',
      order: 0,
    );
    final turkceTopics = [
      'Kelime ve Kelime Gruplarında Anlam',
      'Geçiş ve Bağlantı İfadeleri - Yabancı Kelimelerin Türkçe Karşılıkları',
      'Anlam Özelliklerine Göre Sözcükler',
      'Sözcükler Arası Anlam İlişkileri',
      'Deyimler',
      'Söz Sanatları',
      'Neden-Sonuç, Amaç-Sonuç, Koşul-Sonuç',
      'Nesnel ve Öznel Anlatım',
      'Cümlede Kavramlar ve Duygular',
      'Cümle Tamamlama - Oluşturma - Birleştirme',
      'Cümle Yorumlama, Çıkarım, Kesin Yargı',
      'Atasözü - Özdeyiş',
      'Metnin Konusu - Başlığı',
      'Ana Fikir - Anahtar Sözcük',
      'Yardımcı Düşünce - Soru-Cevap',
      'Metnin Hikâye Unsurları - 5N 1K - Kişi Ağızları',
      'Metinde Gerçek ve Kurgu Unsurlar',
      'Metin Karşılaştırma - Metinde Kavramlar',
      'Metinlerin Yazılış Amaçları',
      'Anlatım Biçimleri',
      'Düşünceyi Geliştirme Yolları ve Dil-Anlatım Özellikleri',
      'Olayları Oluş Sırasına Koyma - Metin Tamamlama',
      'Akışı Bozan Cümle - Metni İkiye Bölme',
      'Şiirde Duygu, Tema - Duyular, Duygular, Karakter',
      'Görsel Yorumlama',
      'Tablo - Grafik - Kroki - Harita Okuma',
      'Sözel Mantık - Muhakeme',
      'Fiilimsi - Çekimli Fiil Farkı / İsim-Fiil',
      'Sıfat-Fiil',
      'Zarf-Fiil',
      'Temel Ögeler (Yüklem)',
      'Temel Ögeler (Özne)',
      'Yardımcı Ögeler (Nesne)',
      'Yardımcı Ögeler (Yer Tamlayıcısı)',
      'Yardımcı Ögeler (Zarf Tamlayıcısı - Ara Söz - Vurgu)',
      'Özne - Yüklem İlişkisi',
      'Nesne - Yüklem İlişkisi',
      'Yüklemin Yerine ve Türüne Göre Cümleler',
      'Anlamına Göre Cümleler',
      'Yapısına Göre Cümleler',
      'Büyük Harflerin Kullanıldığı Yerler',
      'Sayıların ve Kısaltmaların Yazımı, Ses Bilgisi Kuralları ile İlgili Yazım Yanlışları',
      'Mi, Ki ve De\'nin Yazımı - Yazımı Karıştırılan Sözcükler',
      'Bitişik, Ayrı Yazılan Sözcükler - İkilemelerin Pekiştirmelerin - Satır Sonuna Sığmayan Sözcüklerin Yazımı',
      'Nokta - Virgül - Noktalı Virgül - İki Nokta',
      'Soru İşareti - Ünlem',
      'Üç Nokta - Eğik Çizgi',
      'Kesme İşareti - Kısa Çizgi - Uzun Çizgi',
      'Yay Ayraç - Köşeli Ayraç - Tırnak İşareti',
      'Bilgilendirici Metinler',
      'Hikâye Edici Metinler',
      'Özne - Yüklem Uyumsuzluğu',
      'Öge Eksikliği',
      'Eylemsi, Ek Eylem, Yardımcı Fiil Eksiklikleri - Tamlama Yanlışları - Çatı Uyumsuzluğu',
      'Tamlama Yanlışlıkları - Çatı Uyumsuzluğu, Zamir Eksikliği',
      'Bağlaç Yanlışlıkları - Yanlış Ek Kullanımı',
    ];
    for (var i = 0; i < turkceTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_turkce_1_${i + 1}',
        unitId: uTurkce1,
        name: turkceTopics[i],
        order: i,
      );
    }

    // T.C. İnkılap Tarihi ve Atatürkçülük
    const cInkilap = 'course_8_inkilap';
    await _setCourse(
      firestore,
      courseId: cInkilap,
      classLevel: classLevel,
      name: 'T.C. İnkılap Tarihi ve Atatürkçülük',
    );
    const uInkilap1 = 'unit_8_inkilap_1';
    await _setUnit(
      firestore,
      unitId: uInkilap1,
      courseId: cInkilap,
      name: 'Konular',
      order: 0,
    );
    final inkilapTopics = [
      'Avrupa\'daki Gelişmeler ve Osmanlı',
      'Mustafa Kemal\'in Çocukluk Dönemi ve Öğrenim Hayatı',
      'Mustafa Kemal\'in Askerlik Hayatı',
      'Birinci Dünya Savaşı',
      'Birinci Dünya Savaşı\'nda Osmanlı Devleti',
      'Mondros Ateşkes Anlaşması\'nın İmzalanması ve Uygulanması',
      'Kuva-yı Milliye Hareketi',
      'Millî Mücadele\'nin Hazırlık Dönemi',
      'Misakımilli\'nin Kabulü ve Büyük Millet Meclisinin Açılması',
      'Millî Mücadele Dönemi\'nde Doğu ve Güney Cepheleri',
      'Millî Mücadele Dönemi\'nde Batı Cephesi',
      'Sakarya Meydan Savaşı\'ndan Lozan Barış Antlaşması\'na Mustafa Kemal',
      'Atatürk İlkeleri',
      'Siyasi ve Hukuki Alanda Yapılan İnkılaplar',
      'Eğitim ve Kültür Alanında Yapılan İnkılaplar',
      'Toplumsal Alanda Yapılan İnkılaplar',
      'Ekonomik Alanda Yapılan İnkılaplar - Atatürk ve Sağlık',
      'Atatürk İlke ve İnkılaplarını Oluşturan Temel Esaslar',
      'Atatürk Dönemi\'nde Demokratikleşme Yolunda Atılan Adımlar',
      'Mustafa Kemal\'e Suikast Girişimi - Türkiye Cumhuriyeti\'ne Yönelik Tehditler',
      'Türk Dış Politikasının Temel İlke ve Amaçları',
      'Türk Dış Politikasında Yaşanan Gelişmeler',
      'Atatürk\'ün Ölümü ve Yansımaları - Atatürk\'ün Eserleri',
      'İkinci Dünya Savaşı ve Savaşın Türkiye\'ye Etkileri',
    ];
    for (var i = 0; i < inkilapTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_inkilap_1_${i + 1}',
        unitId: uInkilap1,
        name: inkilapTopics[i],
        order: i,
      );
    }

    // Din Kültürü ve Ahlak Bilgisi
    const cDin = 'course_8_din';
    await _setCourse(
      firestore,
      courseId: cDin,
      classLevel: classLevel,
      name: 'Din Kültürü ve Ahlak Bilgisi',
    );
    const uDin1 = 'unit_8_din_1';
    await _setUnit(
      firestore,
      unitId: uDin1,
      courseId: cDin,
      name: 'Konular',
      order: 0,
    );
    final dinTopics = [
      'Kader İnancı',
      'Zekat ve Sadaka',
      'Din ve Hayat',
      'Hz. Muhammed\'in Örnekliği',
      'Kur\'an-ı Kerim ve Özellikleri',
    ];
    for (var i = 0; i < dinTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_din_1_${i + 1}',
        unitId: uDin1,
        name: dinTopics[i],
        order: i,
      );
    }

    // İngilizce
    const cIng = 'course_8_ingilizce';
    await _setCourse(
      firestore,
      courseId: cIng,
      classLevel: classLevel,
      name: 'İngilizce',
    );
    const uIng1 = 'unit_8_ingilizce_1';
    await _setUnit(
      firestore,
      unitId: uIng1,
      courseId: cIng,
      name: 'Konular',
      order: 0,
    );
    final ingTopics = [
      'Friendship',
      'Teen Life',
      'In The Kitchen',
      'On The Phone',
      'The Internet',
      'Adventures',
      'Tourism',
      'Chores',
      'Science',
      'Natural Forces',
    ];
    for (var i = 0; i < ingTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_ingilizce_1_${i + 1}',
        unitId: uIng1,
        name: ingTopics[i],
        order: i,
      );
    }

    // Matematik
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
      name: 'Konular',
      order: 0,
    );
    final matTopics = [
      'Pozitif Tam Sayıların Çarpanları',
      'Ebob ve Ekok',
      'Aralarında Asal Sayılar',
      'Tam Sayıların Tam Sayı Kuvvetleri',
      'Üslü İfadelerle İlgili Temel Kurallar',
      'Ondalık Gösterimlerin Çözümlenmesi',
      'Çok Küçük ve Çok Büyük Sayıların Bilimsel Gösterimi',
      'Tamkare Sayılar ve Tamkare Sayıların Karekökünü Alma',
      'Tamkare Olmayan Karekökli Sayıların Yaklaşık Değerini Bulma',
      'Karekökli İfadelerle İşlemler',
      'İrrasyonel Sayılar ve Gerçek Sayılar',
      'Veri Analizi',
      'Basit Olayların Olma Olasılığı',
      'Cebirsel İfadeler ve Özdeşlikler',
      'Bir Bilinmeyenli Denklemler',
      'Koordinat Sistemi',
      'Doğrusal Denklemlerin Grafiği',
      'Doğrusal İlişki ve Grafiği',
      'Eğim',
      'Eşitsizlikler',
      'Üçgenin Yardımcı Elemanları',
      'Açı Kenar Bağıntıları',
      'Pisagor Bağıntısı',
      'Eşlik ve Benzerlik',
      'Dönüşüm Geometrisi',
      'Prizmalar',
      'Dik Dairesel Silindir',
      'Dik Piramit ve Dik Koni',
    ];
    for (var i = 0; i < matTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matTopics[i],
        order: i,
      );
    }

    // Fen Bilimleri
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
      name: 'Konular',
      order: 0,
    );
    final fenTopics = [
      'Mevsimlerin Oluşumu',
      'İklim ve Hava Olayları',
      'DNA ve Genetik Kod',
      'Kalıtım',
      'Mutasyon ve Modifikasyon',
      'Adaptasyon (Çevreye Uyum)',
      'Biyoteknoloji',
      'Katı Basıncı',
      'Sıvı Basıncı',
      'Gaz Basıncı',
      'Basıncın Günlük Yaşam ve Teknolojideki Uygulamaları',
      'Periyodik Sistem',
      'Fiziksel ve Kimyasal Değişim',
      'Kimyasal Tepkimeler',
      'Asitler ve Bazlar',
      'Maddenin Isı ile Etkileşimi',
      'Türkiye\'de Kimya Endüstrisi',
      'Makaralar',
      'Kaldıraçlar',
      'Eğik Düzlem',
      'Çıkrık',
      'Dişli Çarklar ve Kasnaklar',
      'Bileşik Makineler',
      'Besin Zinciri ve Enerji Akışı',
      'Enerji Dönüşümleri',
      'Madde Döngüleri ve Çevre Sorunları',
      'Sürdürülebilir Kalkınma',
      'Elektrik Yükleri ve Elektriklenme',
      'Elektrik Yüklü Cisimler',
      'Elektrik Enerjisinin Dönüşümü',
    ];
    for (var i = 0; i < fenTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_8_fen_1_${i + 1}',
        unitId: uFen1,
        name: fenTopics[i],
        order: i,
      );
    }
  }

  // -------------------------
  // 9. SINIF
  // -------------------------
  static Future<void> _seedGrade9(FirebaseFirestore firestore) async {
    const classLevel = '9. Sınıf';

    // Matematik
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
      name: 'SAYILAR',
      order: 0,
    );
    final matUnit1Topics = [
      'Gerçek Sayıların Üslü Gösterimi',
      'Gerçek Sayıların Köklü Gösterimi',
      'Gerçek Sayılarda Küme',
      'Gerçek Sayılarda Sayı Aralıkları',
      'Gerçek Sayılarda Mutlak Değerli Aralıklar',
      'Sayı Kümelerinde Sıralama',
      'Önerme',
      'Gerçek Sayılarda İşlem Öncelikleri',
      'Özdeşlikler',
      'Üslü Denklemler İç-içe Kökler',
    ];
    for (var i = 0; i < matUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matUnit1Topics[i],
        order: i,
      );
    }

    const uMat2 = 'unit_9_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'NİCELİKLER VE DEĞİŞİMLER',
      order: 1,
    );
    final matUnit2Topics = [
      'Doğrusal Fonksiyonlar',
      'Parçalı Fonksiyon ve Sabit Fonksiyon',
      'Fonksiyonlarda Dönüşümler',
      'Mutlak Değerli Fonksiyonlar',
      'Fonksiyonlarda Eşitsizlikler',
    ];
    for (var i = 0; i < matUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_2_${i + 1}',
        unitId: uMat2,
        name: matUnit2Topics[i],
        order: i,
      );
    }

    const uMat3 = 'unit_9_matematik_3';
    await _setUnit(
      firestore,
      unitId: uMat3,
      courseId: cMat,
      name: 'GEOMETRİK ŞEKİLLER',
      order: 2,
    );
    final matUnit3Topics = [
      'Üçgende Açılar',
      'Açı-Kenar Bağıntıları',
    ];
    for (var i = 0; i < matUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_3_${i + 1}',
        unitId: uMat3,
        name: matUnit3Topics[i],
        order: i,
      );
    }

    const uMat4 = 'unit_9_matematik_4';
    await _setUnit(
      firestore,
      unitId: uMat4,
      courseId: cMat,
      name: 'EŞLİK VE BENZERLİK',
      order: 3,
    );
    final matUnit4Topics = [
      'Dönüşüm Geometrisi',
      'Eş Üçgenler',
      'Benzer Üçgenler',
      'Öklid Bağıntısı',
      'Pisagor Bağıntısı',
      'Açı-Kenar Bağıntıları',
      'İkizkenar-Eşkenar Üçgende Öklid ve Pisagor',
    ];
    for (var i = 0; i < matUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_4_${i + 1}',
        unitId: uMat4,
        name: matUnit4Topics[i],
        order: i,
      );
    }

    const uMat5 = 'unit_9_matematik_5';
    await _setUnit(
      firestore,
      unitId: uMat5,
      courseId: cMat,
      name: 'ALGORİTMA VE BİLİŞİM',
      order: 4,
    );
    final matUnit5Topics = [
      'Algoritma Temelli Yaklaşımlarla Problem Çözme',
      'Çizge Kuramı',
      'Algoritmik Yapılar İçerisindeki Mantık Bağlaçları ve Niceleyicileri',
    ];
    for (var i = 0; i < matUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_5_${i + 1}',
        unitId: uMat5,
        name: matUnit5Topics[i],
        order: i,
      );
    }

    const uMat6 = 'unit_9_matematik_6';
    await _setUnit(
      firestore,
      unitId: uMat6,
      courseId: cMat,
      name: 'İSTATİSTİKSEL ARAŞTIRMA SÜRECİ',
      order: 5,
    );
    final matUnit6Topics = [
      'İstatistiksel Araştırma Süreci',
      'Grafik Çeşitlerinin İncelenmesi',
      'Veri ile İlgili Temel Bilgiler',
      'Tek Nicel Veriye Dayalı İstatistiksel Araştırmalarda Bağlam',
    ];
    for (var i = 0; i < matUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_6_${i + 1}',
        unitId: uMat6,
        name: matUnit6Topics[i],
        order: i,
      );
    }

    const uMat7 = 'unit_9_matematik_7';
    await _setUnit(
      firestore,
      unitId: uMat7,
      courseId: cMat,
      name: 'VERİDEN OLASILIĞA',
      order: 6,
    );
    final matUnit7Topics = [
      'Olayların Olasılığını Gözleme Dayalı Tahmin Etme',
      'Olayların Olasılığına İlişkin Tümevarımsal Akıl Yürütme',
    ];
    for (var i = 0; i < matUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_matematik_7_${i + 1}',
        unitId: uMat7,
        name: matUnit7Topics[i],
        order: i,
      );
    }

    // Fizik
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
      name: 'FİZİK BİLİMİ VE KARİYER KEŞFİ',
      order: 0,
    );
    final fizikUnit1Topics = [
      'Fizik bilimi',
      'Fizik biliminin alt dalları',
      'Fizik bilimine yön verenler',
      'Fizik bilimi ile ilgili kariyer keşfi',
    ];
    for (var i = 0; i < fizikUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_fizik_1_${i + 1}',
        unitId: uFiz1,
        name: fizikUnit1Topics[i],
        order: i,
      );
    }

    const uFiz2 = 'unit_9_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'KUVVET VE HAREKET',
      order: 1,
    );
    final fizikUnit2Topics = [
      'Temel ve türetilmiş nicelikler',
      'Skaler ve vektörel nicelikler',
      'Vektörler',
      'Doğadaki temel kuvvetler',
      'Hareket ve hareket türleri',
    ];
    for (var i = 0; i < fizikUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_fizik_2_${i + 1}',
        unitId: uFiz2,
        name: fizikUnit2Topics[i],
        order: i,
      );
    }

    const uFiz3 = 'unit_9_fizik_3';
    await _setUnit(
      firestore,
      unitId: uFiz3,
      courseId: cFizik,
      name: 'AKIŞKANLAR',
      order: 2,
    );
    final fizikUnit3Topics = [
      'Basınç',
      'Sıvılarda basınç',
      'Açık Hava Basıncı',
      'Kaldırma Kuvveti',
      'Bernoulli İlkesi',
    ];
    for (var i = 0; i < fizikUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_fizik_3_${i + 1}',
        unitId: uFiz3,
        name: fizikUnit3Topics[i],
        order: i,
      );
    }

    const uFiz4 = 'unit_9_fizik_4';
    await _setUnit(
      firestore,
      unitId: uFiz4,
      courseId: cFizik,
      name: 'ENERJİ',
      order: 3,
    );
    final fizikUnit4Topics = [
      'İç Enerji Isı ve Sıcaklık Arasındaki İlişki',
      'Isı Öz Isı Isı Sığası ve Sıcaklık Farkı Arasındaki İlişki',
      'Hâl Değişimi',
      'Isıl Denge',
      'Isı Aktarım Yolları',
      'Isı İletim Hızı',
    ];
    for (var i = 0; i < fizikUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_fizik_4_${i + 1}',
        unitId: uFiz4,
        name: fizikUnit4Topics[i],
        order: i,
      );
    }

    // Kimya
    const cKimya = 'course_9_kimya';
    await _setCourse(
      firestore,
      courseId: cKimya,
      classLevel: classLevel,
      name: 'Kimya',
    );
    const uKimya1 = 'unit_9_kimya_1';
    await _setUnit(
      firestore,
      unitId: uKimya1,
      courseId: cKimya,
      name: 'ATOMDAN PERİYODİK TABLOYA',
      order: 0,
    );
    final kimyaUnit1Topics = [
      'Atom Teorileri ve Atomun Yapısı',
      'Bohr Atom Teorisi ve Elektron Geçişleri',
      'Atom Orbitalleri ve Elektron Dizilimi',
      'Periyodik Tabloda Yer Bulma',
      'Bazı Gruplar ve Özellikleri',
      'Atomdan İyona',
      'Atom Yarıçapı',
      'İyonlaşma Enerjisi',
      'Elektronegatiflik',
    ];
    for (var i = 0; i < kimyaUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_kimya_1_${i + 1}',
        unitId: uKimya1,
        name: kimyaUnit1Topics[i],
        order: i,
      );
    }

    const uKimya2 = 'unit_9_kimya_2';
    await _setUnit(
      firestore,
      unitId: uKimya2,
      courseId: cKimya,
      name: 'ETKİLEŞİMLER',
      order: 1,
    );
    final kimyaUnit2Topics = [
      'Metalik Bağ',
      'İyonik Bağ',
      'Kovalent Bağ',
      'Lewis Nokta Yapısı ve Molekül Polarlığı',
      'Molekül Polarlığı ve Apolarlığı',
    ];
    for (var i = 0; i < kimyaUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_kimya_2_${i + 1}',
        unitId: uKimya2,
        name: kimyaUnit2Topics[i],
        order: i,
      );
    }

    const uKimya3 = 'unit_9_kimya_3';
    await _setUnit(
      firestore,
      unitId: uKimya3,
      courseId: cKimya,
      name: 'ETKİLEŞİMDEN MADDEYE',
      order: 2,
    );
    final kimyaUnit3Topics = [
      'İyonik Bağlı Bileşiklerin Adlandırılması',
      'Kovalent Bağlı Bileşiklerin Adlandırılması',
      'Moleküller Arası Etkileşimler',
      'Katılar ve Özellikleri',
      'Sıvıların Özellikleri ve Buhar Basıncı',
      'Kaynama ve Buharlaşma',
      'Viskozite',
      'Adezyon-Kohezyon Kuvvetleri ve Yüzey Gerilimi',
    ];
    for (var i = 0; i < kimyaUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_kimya_3_${i + 1}',
        unitId: uKimya3,
        name: kimyaUnit3Topics[i],
        order: i,
      );
    }

    const uKimya4 = 'unit_9_kimya_4';
    await _setUnit(
      firestore,
      unitId: uKimya4,
      courseId: cKimya,
      name: 'NANOPARÇACIKLAR VE EKOLOJİK SÜRDÜRÜLEBİLİRLİK',
      order: 3,
    );
    final kimyaUnit4Topics = [
      'Metal Nanoparçacıklar',
      'Yeşil Kimya',
      'Metal, Alaşım ve Metal Nanoparçacıkların Çevresel Etkileri',
    ];
    for (var i = 0; i < kimyaUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_kimya_4_${i + 1}',
        unitId: uKimya4,
        name: kimyaUnit4Topics[i],
        order: i,
      );
    }

    const uKimya5 = 'unit_9_kimya_5';
    await _setUnit(
      firestore,
      unitId: uKimya5,
      courseId: cKimya,
      name: 'KİMYA HAYATTIR',
      order: 4,
    );
    final kimyaUnit5Topics = [
      'Günlük Hayatta Kimya',
      'Kimyanın Alt Disiplinleri',
      'Kimyasal Maddelerin Kullanımı ve Güvenlik',
    ];
    for (var i = 0; i < kimyaUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_kimya_5_${i + 1}',
        unitId: uKimya5,
        name: kimyaUnit5Topics[i],
        order: i,
      );
    }

    // Biyoloji
    const cBiyo = 'course_9_biyoloji';
    await _setCourse(
      firestore,
      courseId: cBiyo,
      classLevel: classLevel,
      name: 'Biyoloji',
    );
    const uBiyo1 = 'unit_9_biyoloji_1';
    await _setUnit(
      firestore,
      unitId: uBiyo1,
      courseId: cBiyo,
      name: 'YAŞAM',
      order: 0,
    );
    final biyoUnit1Topics = [
      'Biyolojinin Önemi ve Biyoloji Biliminin Gelişimindeki Dönüm Noktaları',
      'Bilimin Doğası, Bilimsel Araştırma Süreçleri ve Bilim Etiği',
      'Canlıların Ortak Özellikleri ve Grafik Yorumlama',
      'Virüsler',
      'Sınıflandırmada Temel Yaklaşımlar ve Modern Sınıflandırma',
      'Bakteriler ve Arkeler',
      'Protista, Bitki ve Mantar',
      'Hayvanlar',
      'Biyoçeşitlilik',
    ];
    for (var i = 0; i < biyoUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_biyoloji_1_${i + 1}',
        unitId: uBiyo1,
        name: biyoUnit1Topics[i],
        order: i,
      );
    }

    const uBiyo2 = 'unit_9_biyoloji_2';
    await _setUnit(
      firestore,
      unitId: uBiyo2,
      courseId: cBiyo,
      name: 'ORGANİZASYON',
      order: 1,
    );
    final biyoUnit2Topics = [
      'İnorganik Moleküller',
      'Karbohidratlar',
      'Lipitler',
      'Proteinler',
      'Karbohidratlar, Yağlar ve Proteinler',
      'Enzimler',
      'Vitaminler ve Nükleik Asitler',
      'Hücre Teorisine Giriş, Prokaryot ve Ökaryot Hücreler',
      'Hücre Zarı, Sitoplazma, Ribozom, Sentrozom ve Endoplazmik Retikulum',
      'Golgi Aygıtı, Lizozom, Koful ve Peroksizom',
      'Mitokondri, Plastitler ve Çekirdek',
      'Hücre Organelleri',
      'Hücrelerin Karşılaştırılması',
      'Difüzyon ve Ozmoz',
      'Aktif Taşıma, Endositoz ve Ekzositoz',
      'Hücre, Doku, Organ ve Sistemlerin Organizasyonu',
    ];
    for (var i = 0; i < biyoUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_biyoloji_2_${i + 1}',
        unitId: uBiyo2,
        name: biyoUnit2Topics[i],
        order: i,
      );
    }

    // Coğrafya
    const cCografya = 'course_9_cografya';
    await _setCourse(
      firestore,
      courseId: cCografya,
      classLevel: classLevel,
      name: 'Coğrafya',
    );
    const uCografya1 = 'unit_9_cografya_1';
    await _setUnit(
      firestore,
      unitId: uCografya1,
      courseId: cCografya,
      name: 'BEŞERİ SİSTEMLER VE SÜREÇLER',
      order: 0,
    );
    final cografyaUnit1Topics = [
      'Nüfusun Tarihsel Değişimi ve Geleceği',
      'Nüfusun Dağılışı ve Hareketleri',
      'Demografik Dönüşüm Süreci ve Nüfus Piramitleri',
      'Nüfus Politikaları',
    ];
    for (var i = 0; i < cografyaUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_1_${i + 1}',
        unitId: uCografya1,
        name: cografyaUnit1Topics[i],
        order: i,
      );
    }

    const uCografya2 = 'unit_9_cografya_2';
    await _setUnit(
      firestore,
      unitId: uCografya2,
      courseId: cCografya,
      name: 'COĞRAFYANIN DOĞASI',
      order: 1,
    );
    final cografyaUnit2Topics = [
      'Coğrafya Biliminin Konusu ve Bölümleri',
      'Coğrafya Biliminin Gelişimi',
    ];
    for (var i = 0; i < cografyaUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_2_${i + 1}',
        unitId: uCografya2,
        name: cografyaUnit2Topics[i],
        order: i,
      );
    }

    const uCografya3 = 'unit_9_cografya_3';
    await _setUnit(
      firestore,
      unitId: uCografya3,
      courseId: cCografya,
      name: 'MEKÂNSAL BİLGİ TEKNOLOJİLERİ',
      order: 2,
    );
    final cografyaUnit3Topics = [
      'Mekânın Sembolik Dili: Harita',
      'Türkiye\'nin Coğrafi Konumu',
      'Mekânsal Bilgi Teknolojilerinin Bileşenleri',
    ];
    for (var i = 0; i < cografyaUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_3_${i + 1}',
        unitId: uCografya3,
        name: cografyaUnit3Topics[i],
        order: i,
      );
    }

    const uCografya4 = 'unit_9_cografya_4';
    await _setUnit(
      firestore,
      unitId: uCografya4,
      courseId: cCografya,
      name: 'DOĞAL SİSTEMLER VE SÜREÇLER',
      order: 3,
    );
    final cografyaUnit4Topics = [
      'Hava Olayları',
      'İklim Sistemi',
      'İklim Türleri',
      'İklim Sisteminde Yaşanan Değişiklikler',
    ];
    for (var i = 0; i < cografyaUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_4_${i + 1}',
        unitId: uCografya4,
        name: cografyaUnit4Topics[i],
        order: i,
      );
    }

    const uCografya5 = 'unit_9_cografya_5';
    await _setUnit(
      firestore,
      unitId: uCografya5,
      courseId: cCografya,
      name: 'EKONOMİK FAALİYETLER VE ETKİLERİ',
      order: 4,
    );
    final cografyaUnit5Topics = [
      'Ekonomik Faaliyetleri Etkileyen Doğal Faktörler',
      'Ekonomik Faaliyetleri Etkileyen Beşeri Faktörler',
    ];
    for (var i = 0; i < cografyaUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_5_${i + 1}',
        unitId: uCografya5,
        name: cografyaUnit5Topics[i],
        order: i,
      );
    }

    const uCografya6 = 'unit_9_cografya_6';
    await _setUnit(
      firestore,
      unitId: uCografya6,
      courseId: cCografya,
      name: 'AFETLER VE SÜRDÜRÜLEBİLİR ÇEVRE',
      order: 5,
    );
    final cografyaUnit6Topics = [
      'Tehlike, Risk ve Afet',
      'Afet Türleri',
      'Bütüncül Afet Yönetimi',
    ];
    for (var i = 0; i < cografyaUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_6_${i + 1}',
        unitId: uCografya6,
        name: cografyaUnit6Topics[i],
        order: i,
      );
    }

    const uCografya7 = 'unit_9_cografya_7';
    await _setUnit(
      firestore,
      unitId: uCografya7,
      courseId: cCografya,
      name: 'BÖLGELER, ÜLKELER VE KÜRESEL BAĞLANTILAR',
      order: 6,
    );
    final cografyaUnit7Topics = [
      'Bölge Belirleme Kriterleri ve Bölge Türleri',
      'Kriterlere Göre Bölge Sınırları',
      'Bölge Sınırlarında Değişim',
    ];
    for (var i = 0; i < cografyaUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_cografya_7_${i + 1}',
        unitId: uCografya7,
        name: cografyaUnit7Topics[i],
        order: i,
      );
    }

    // Tarih
    const cTarih = 'course_9_tarih';
    await _setCourse(
      firestore,
      courseId: cTarih,
      classLevel: classLevel,
      name: 'Tarih',
    );
    const uTarih1 = 'unit_9_tarih_1';
    await _setUnit(
      firestore,
      unitId: uTarih1,
      courseId: cTarih,
      name: 'GEÇMİŞİN İNŞA SÜRECİNDE TARİH',
      order: 0,
    );
    final tarihUnit1Topics = [
      'Tarih Öğrenmenin Faydaları',
      'Tarih Doğası',
      'Tarihsel Bilginin Üretim Süreci',
      'Tarih Araştırma ve Yazımında Dijital Dönüşüm',
    ];
    for (var i = 0; i < tarihUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tarih_1_${i + 1}',
        unitId: uTarih1,
        name: tarihUnit1Topics[i],
        order: i,
      );
    }

    const uTarih2 = 'unit_9_tarih_2';
    await _setUnit(
      firestore,
      unitId: uTarih2,
      courseId: cTarih,
      name: 'ESKİ ÇAĞ MEDENİYETLERİ',
      order: 1,
    );
    final tarihUnit2Topics = [
      'Tarım Devrimi\'nin Eski Çağ\'a Etkileri',
      'Eski Çağ\'da Yönetenler ve Savaşanlar',
      'Eski Çağ\'da Hukuk',
      'Eski Çağ\'da İnanç Bilim ve Sanat',
      'Türklerde Konargöçer Yaşam',
    ];
    for (var i = 0; i < tarihUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tarih_2_${i + 1}',
        unitId: uTarih2,
        name: tarihUnit2Topics[i],
        order: i,
      );
    }

    const uTarih3 = 'unit_9_tarih_3';
    await _setUnit(
      firestore,
      unitId: uTarih3,
      courseId: cTarih,
      name: 'ORTA ÇAĞ MEDENİYETLERİ',
      order: 2,
    );
    final tarihUnit3Topics = [
      'Orta Çağ\'da Kitlesel Göçler',
      'Orta Çağ\'da Siyasi ve Askeri Gelişmeler',
      'Orta Çağ\'da Ticaret Yolları',
      'Orta Çağ\'da Bilim, Kültür, Sanat',
    ];
    for (var i = 0; i < tarihUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tarih_3_${i + 1}',
        unitId: uTarih3,
        name: tarihUnit3Topics[i],
        order: i,
      );
    }

    // Türk Dili ve Edebiyatı
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
      name: 'DİLİN ZENGİNLİĞİ',
      order: 0,
    );
    final tdeUnit1Topics = [
      'ROMAN',
      'ROMANIN TARİHİ GELİŞİMİ',
      'ROMANIN YAPI UNSURLARI',
      'ROMANIN BÖLÜMLERİ',
      'ROMANDA ANLATICI',
      'ROMANDA BAKIŞ AÇILARI',
      'ROMANDA ÇATIŞMA',
      'ROMAN-HİKÂYE KARŞILAŞTIRMASI',
      'ROMANDA ANLATIM TEKNİKLERİ',
      'CUMHURİYET DÖNEMİNDE ROMAN',
      'CUMHURİYET DÖNEMİNDE ESER VEREN BAZI SANATÇILAR',
      'TİYATRO',
      'ELEŞTİRİ',
      'OTOBİYOGRAFİ',
    ];
    for (var i = 0; i < tdeUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tde_1_${i + 1}',
        unitId: uTde1,
        name: tdeUnit1Topics[i],
        order: i,
      );
    }

    const uTde2 = 'unit_9_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'SÖZÜN İNCELİĞİ',
      order: 1,
    );
    final tdeUnit2Topics = [
      'ŞİİR',
      'EDEBİ SANATLAR',
      'EDEBİYAT',
      'GÜZEL SANATLAR İÇİNDE EDEBİYATIN YERİ',
      'DİL NEDİR?',
      'SÖZCÜKTE ANLAM',
      'PARAGRAF',
      'DENEME',
      'MÜLAKAT',
      'SES BİLGİSİ',
      'YAZIM KURALLARI',
      'NOKTALAMA İŞARETLERİ',
    ];
    for (var i = 0; i < tdeUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tde_2_${i + 1}',
        unitId: uTde2,
        name: tdeUnit2Topics[i],
        order: i,
      );
    }

    const uTde3 = 'unit_9_tde_3';
    await _setUnit(
      firestore,
      unitId: uTde3,
      courseId: cTde,
      name: 'ANLAM ARAYIŞI',
      order: 2,
    );
    final tdeUnit3Topics = [
      'HİKÂYE',
      'HİKÂYENİN TARİHİ GELİŞİMİ',
      'HİKÂYEDE KONU-TEMA-İLETİ VE YAPI UNSURLARI',
      'HİKÂYE TÜRÜNDE ESER VEREN BAZI SANATÇILAR',
      'ANI',
      'ŞİİR',
      'İSTİKLAL MARŞININ İNCELENMESİ',
      'ŞİİR TÜRLERİ',
      'METİN',
      'SUNUM',
    ];
    for (var i = 0; i < tdeUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tde_3_${i + 1}',
        unitId: uTde3,
        name: tdeUnit3Topics[i],
        order: i,
      );
    }

    const uTde4 = 'unit_9_tde_4';
    await _setUnit(
      firestore,
      unitId: uTde4,
      courseId: cTde,
      name: 'ANLAMIN YAPI TAŞLARI',
      order: 3,
    );
    final tdeUnit4Topics = [
      'HİKÂYE',
      'SÖZCÜKTE YAPI',
      'ŞİİR',
      'ESKİ ANADOLU TÜRKÇESİ',
      'GEZİ YAZISI (SEYAHATNAME)',
    ];
    for (var i = 0; i < tdeUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_9_tde_4_${i + 1}',
        unitId: uTde4,
        name: tdeUnit4Topics[i],
        order: i,
      );
    }
  }

  // -------------------------
  // 10. SINIF
  // -------------------------
  static Future<void> _seedGrade10(FirebaseFirestore firestore) async {
    const classLevel = '10. Sınıf';

    // Matematik
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
      name: 'GEOMETRİK ŞEKİLLER',
      order: 0,
    );
    final matUnit1Topics = [
      'Dik Üçgende Trigonometri',
      'Trigonometrik Özdeşlikler',
      'Birim Çember Tanıyalım',
      'Yönlü Açıyı Tanıyalım',
      'Trigonometrik Özdeşlikler ve Oranlar',
      'Üçgende İç Açıortay Teoremini Tanıyalım',
      'Üçgende Dış Açıortay Teoremini Tanıyalım',
      'Açıortaydan Kollara Çizilen Dikler',
      'Üçgende İç Teğet ve Dış Teğet Çemberin Merkezleri',
      'Üçgende Açıortay',
      'Üçgende Kenarortay',
      'Üçgende Kenarorta Dikme Doğrusu',
      'Üçgende Yüksekliklerin Kesim Noktası',
      'Üçgende Alan',
      'Sinüs ve Kosinüs Teoremi',
    ];
    for (var i = 0; i < matUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matUnit1Topics[i],
        order: i,
      );
    }

    const uMat2 = 'unit_10_matematik_2';
    await _setUnit(
      firestore,
      unitId: uMat2,
      courseId: cMat,
      name: 'NİCELİKLER VE DEĞİŞİMLER',
      order: 1,
    );
    final matUnit2Topics = [
      'Fonksiyonların Tanımı ve Görüntü Kümeleri',
      'Fonksiyonların Nitel Özellikleri',
      'Tek-Çift Fonksiyonlar ve Grafikler',
      'Gerçek Sayılarda Tanımlı Karesel Referans Fonksiyonlar ve Nitel Özellikleri',
      'Parabolün Tepe Noktası',
      'Parabolün En Büyük ve En Küçük Değeri',
      'Parabolün Simetri Ekseni',
      'Karesel Fonksiyonların Grafikleri',
      'Karesel Fonksiyonların Nitel Özellikleri',
      'Karekök Referans Fonksiyonu ve Nitel Özellikleri',
      'Rasyonel Referans Fonksiyonu ve Nitel Özellikleri',
      'Doğrusal Fonksiyonların Ters Fonksiyonları',
      'Rasyonel Fonksiyonların Ters Fonksiyonları',
      'Karesel Fonksiyonların Ters Fonksiyonları',
      'Karekök Fonksiyonların Ters Fonksiyonları',
      'Fonksiyonların Tersi',
      'Fonksiyonlarla İfade Edilen Denklem ve Eşitsizlik İçeren Problemlerin Çözümü',
    ];
    for (var i = 0; i < matUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_matematik_2_${i + 1}',
        unitId: uMat2,
        name: matUnit2Topics[i],
        order: i,
      );
    }

    const uMat3 = 'unit_10_matematik_3';
    await _setUnit(
      firestore,
      unitId: uMat3,
      courseId: cMat,
      name: 'İSTATİSTİKSEL ARAŞTIRMA SÜRECİ',
      order: 2,
    );
    final matUnit3Topics = [
      'İstatistiksel Araştırma Süreci',
      'İki Kategorik Değişkenin İlişkililiğini İçeren İstatistiksel Problemi Oluşturma',
      'İki Kategorik Değişkenin İlişkililiğini İçeren İstatistiksel Probleme Uygun Verileri Toplama',
      'İki Kategorik Değişkenin İlişkililiğini İçeren İstatistiksel Probleme Uygun Verileri Analize Hazır Hale Getirme',
      'İki Kategorik Değişkenli İstatistiksel Araştırma Süreci',
    ];
    for (var i = 0; i < matUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_matematik_3_${i + 1}',
        unitId: uMat3,
        name: matUnit3Topics[i],
        order: i,
      );
    }

    const uMat4 = 'unit_10_matematik_4';
    await _setUnit(
      firestore,
      unitId: uMat4,
      courseId: cMat,
      name: 'SAYILAR',
      order: 3,
    );
    final matUnit4Topics = [
      'Asal Sayılar ve Bir Sayının Asal Çarpanlarını Tanıyalım',
      'Bir Sayının Bölenlerinin Sayısı',
      'EBOB-EKOK',
      'Bölme ve Bölünebilme',
    ];
    for (var i = 0; i < matUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_matematik_4_${i + 1}',
        unitId: uMat4,
        name: matUnit4Topics[i],
        order: i,
      );
    }

    // Fizik
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
      name: 'KUVVET VE HAREKET',
      order: 0,
    );
    final fizikUnit1Topics = [
      'Yatay Doğrultuda Sabit Hızlı Hareket',
      'İvme ve Hız Değişimi Arasındaki İlişki',
      'Yatay Doğrultuda Sabit İvmeli Hareket',
      'Serbest Düşme Hareketi Yapan Cisimlerin İvme ve Hız Değişimi Arasındaki İlişki',
      'Serbest Düşme Hareketi',
      'İki Boyutta Sabit İvmeli Hareket',
    ];
    for (var i = 0; i < fizikUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_fizik_1_${i + 1}',
        unitId: uFiz1,
        name: fizikUnit1Topics[i],
        order: i,
      );
    }

    const uFiz2 = 'unit_10_fizik_2';
    await _setUnit(
      firestore,
      unitId: uFiz2,
      courseId: cFizik,
      name: 'ENERJİ',
      order: 1,
    );
    final fizikUnit2Topics = [
      'Kuvvet-Yer Değiştirme İlişkisi',
      'İş-Enerji-Güç',
      'Enerji Çeşitleri',
      'Mekanik Enerji',
      'Enerji Kaynakları',
    ];
    for (var i = 0; i < fizikUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_fizik_2_${i + 1}',
        unitId: uFiz2,
        name: fizikUnit2Topics[i],
        order: i,
      );
    }

    const uFiz3 = 'unit_10_fizik_3';
    await _setUnit(
      firestore,
      unitId: uFiz3,
      courseId: cFizik,
      name: 'ELEKTRİK',
      order: 2,
    );
    final fizikUnit3Topics = [
      'Basit Elektrik Devresi ile Su Tesisatının Analogik İlişkisi',
      'Elektrik Yükünün Hareketi ve Elektrik Akımı',
      'Potansiyel Fark, Elektrik Akımı ve Direnç',
      'Dirençlerin Bağlanması ve Ohm Yasası',
      'Üreteçlerin Bağlanması',
      'Elektrik Akımının Oluşturabileceği Tehlikelere Karşı Alınması Gereken Önlemler',
      'Topraklama',
    ];
    for (var i = 0; i < fizikUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_fizik_3_${i + 1}',
        unitId: uFiz3,
        name: fizikUnit3Topics[i],
        order: i,
      );
    }

    const uFiz4 = 'unit_10_fizik_4';
    await _setUnit(
      firestore,
      unitId: uFiz4,
      courseId: cFizik,
      name: 'DALGALAR',
      order: 3,
    );
    final fizikUnit4Topics = [
      'Dalgalar ile İlgili Temel Kavramlar',
      'Dalgaları Özelliklerine Göre Sınıflandırabilme',
      'Dalgaların Yayılma Süratine Etki Eden Faktörler',
      'Periyodik Hareketler',
      'Su Dalgalarında Yansıma ve Kırılma',
      'Rezonans ve Deprem ile İlgili Kavramlar',
      'Deprem ile İlgili Bilimsel Model Oluşturabilme',
    ];
    for (var i = 0; i < fizikUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_fizik_4_${i + 1}',
        unitId: uFiz4,
        name: fizikUnit4Topics[i],
        order: i,
      );
    }

    // Kimya
    const cKimya = 'course_10_kimya';
    await _setCourse(
      firestore,
      courseId: cKimya,
      classLevel: classLevel,
      name: 'Kimya',
    );
    const uKimya1 = 'unit_10_kimya_1';
    await _setUnit(
      firestore,
      unitId: uKimya1,
      courseId: cKimya,
      name: 'ETKİLEŞİM',
      order: 0,
    );
    final kimyaUnit1Topics = [
      'Kimyasal Değişim',
      'Kimyasal Tepkimeler',
      'Kimyasal Tepkimelerin Oluşum Sürecini Modelleme',
      'Çökelme Tepkimeleri',
      'İndirgeme Yükseltgenme Tepkimeleri',
      'Asit-Baz Tepkimeleri',
      'Grup İsimleri - Mol Sayısı',
      'Elementlerin Mol-Tanecik Sayısı - Kütle İlişkisi',
      'Bileşiklerin Mol-Tanecik Sayısı - Kütle İlişkisi',
      'Bileşiklerdeki Atom Sayısı - Atom Kütlesi İlişkisi',
      'Kimyasal Tepkime Denklemlerinin Denkleştirilmesi',
      'Basit Miktar Geçişleri',
      'Artan Madde Problemleri',
      'Verim Problemleri',
      'Saflık Problemleri',
      'Gazların Özellikleri',
      'Gaz Yasaları',
      'Gazların Kinetik Moleküler Teorisi',
      'İdeal Gaz Yasası',
      'Graham Difüzyon ve Efüzyon Yasası',
    ];
    for (var i = 0; i < kimyaUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_kimya_1_${i + 1}',
        unitId: uKimya1,
        name: kimyaUnit1Topics[i],
        order: i,
      );
    }

    const uKimya2 = 'unit_10_kimya_2';
    await _setUnit(
      firestore,
      unitId: uKimya2,
      courseId: cKimya,
      name: 'ÇEŞİTLİLİK',
      order: 1,
    );
    final kimyaUnit2Topics = [
      'Çözünme Süreci ve Maddelerin Birbiri İçindeki Çözünebilirliği',
      'Çözünme Olayının Sınıflandırılması',
      'Derişim Birimleri (Molarite, ppm)',
      'Çözünürlük ve Etki Eden Faktörler',
      'Çözeltilerin Sınıflandırılması',
      'Koligatif Özellikler',
    ];
    for (var i = 0; i < kimyaUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_kimya_2_${i + 1}',
        unitId: uKimya2,
        name: kimyaUnit2Topics[i],
        order: i,
      );
    }

    const uKimya3 = 'unit_10_kimya_3';
    await _setUnit(
      firestore,
      unitId: uKimya3,
      courseId: cKimya,
      name: 'SÜRDÜRÜLEBİLİRLİK',
      order: 2,
    );
    final kimyaUnit3Topics = [
      'Makro ve Mikro Ölçekli Deneyler',
      'Atmosferdeki Tepkimeler ve Küresel Sorunlar',
    ];
    for (var i = 0; i < kimyaUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_kimya_3_${i + 1}',
        unitId: uKimya3,
        name: kimyaUnit3Topics[i],
        order: i,
      );
    }

    // Biyoloji
    const cBiyo = 'course_10_biyoloji';
    await _setCourse(
      firestore,
      courseId: cBiyo,
      classLevel: classLevel,
      name: 'Biyoloji',
    );
    const uBiyo1 = 'unit_10_biyoloji_1';
    await _setUnit(
      firestore,
      unitId: uBiyo1,
      courseId: cBiyo,
      name: 'ENERJİ',
      order: 0,
    );
    final biyoUnit1Topics = [
      'Canlılık İçin Enerjinin Önemi ve ATP',
      'Fotosentez',
      'Fotosentez ve Kemosentez',
      'Canlılarda Sindirim ve Sindirim Yapıları',
      'İnsanda Sindirim',
      'Oksijenli Solunum',
      'Oksijenli Solunum ve Fermantasyon',
    ];
    for (var i = 0; i < biyoUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_biyoloji_1_${i + 1}',
        unitId: uBiyo1,
        name: biyoUnit1Topics[i],
        order: i,
      );
    }

    const uBiyo2 = 'unit_10_biyoloji_2';
    await _setUnit(
      firestore,
      unitId: uBiyo2,
      courseId: cBiyo,
      name: 'EKOLOJİ',
      order: 1,
    );
    final biyoUnit2Topics = [
      'Cansız ve Canlı Bileşenler',
      'Komünite',
      'Popülasyon',
      'Ekosistemdeki Madde ve Enerji Akışı',
      'Ekolojik Sürdürülebilirlik, Ekolojik Ayak İzi',
      'Doğal Çeşitliliğin ve Biyoçeşitliliğin Korunması, Atık Yönetimi',
    ];
    for (var i = 0; i < biyoUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_biyoloji_2_${i + 1}',
        unitId: uBiyo2,
        name: biyoUnit2Topics[i],
        order: i,
      );
    }

    // Coğrafya
    const cCografya = 'course_10_cografya';
    await _setCourse(
      firestore,
      courseId: cCografya,
      classLevel: classLevel,
      name: 'Coğrafya',
    );
    const uCografya1 = 'unit_10_cografya_1';
    await _setUnit(
      firestore,
      unitId: uCografya1,
      courseId: cCografya,
      name: 'COĞRAFYANIN DOĞASI',
      order: 0,
    );
    final cografyaUnit1Topics = [
      'Coğrafi Bakış',
    ];
    for (var i = 0; i < cografyaUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_1_${i + 1}',
        unitId: uCografya1,
        name: cografyaUnit1Topics[i],
        order: i,
      );
    }

    const uCografya2 = 'unit_10_cografya_2';
    await _setUnit(
      firestore,
      unitId: uCografya2,
      courseId: cCografya,
      name: 'MEKÂNSAL BİLGİ TEKNOLOJİLERİ',
      order: 1,
    );
    final cografyaUnit2Topics = [
      'CBS ve Uzaktan Algılamanın Uygulama Alanları',
      'Mekânsal Verilerin Haritalara Aktarılması',
    ];
    for (var i = 0; i < cografyaUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_2_${i + 1}',
        unitId: uCografya2,
        name: cografyaUnit2Topics[i],
        order: i,
      );
    }

    const uCografya3 = 'unit_10_cografya_3';
    await _setUnit(
      firestore,
      unitId: uCografya3,
      courseId: cCografya,
      name: 'DOĞAL SİSTEMLER VE SÜREÇLER',
      order: 2,
    );
    final cografyaUnit3Topics = [
      'Dünya\'nın Oluşumu ve Levha Tektoniği',
      'Levha Hareketleri ve Dağ ve Kıta Oluşumu',
      'Levha Hareketleri ve Volkanizma',
      'Levha Hareketleri ve Depremler',
      'Türkiye\'nin Tektonizması',
      'Jeolojik Zamanlar ve Türkiye\'nin Jeolojik Geçmişi',
      'Kayaçların Ayrışması ve Çözünmesi',
      'Akarsuların Yeryüzünü Şekillendirmesi',
      'Çözünebilen Kayaçlar',
      'Aşınım ve Birikim',
      'Aşınım ve Birikim Süreçlerinde Rüzgarlar',
      'Buzullaşma Alanlarında Aşınım ve Birikim',
      'Dalga ve Akıntıların Oluşturduğu Yer Şekilleri',
      'Yeryüzü Şekilleri ve Beşeri Faaliyet Etkileşimi',
    ];
    for (var i = 0; i < cografyaUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_3_${i + 1}',
        unitId: uCografya3,
        name: cografyaUnit3Topics[i],
        order: i,
      );
    }

    const uCografya4 = 'unit_10_cografya_4';
    await _setUnit(
      firestore,
      unitId: uCografya4,
      courseId: cCografya,
      name: 'BEŞERİ SİSTEMLER VE SÜREÇLER',
      order: 3,
    );
    final cografyaUnit4Topics = [
      'Yerleşmelerin Kuruluşu ve Gelişimi',
      'Yerleşme Yerinin Seçimi ve Gelişimini Etkileyen Faktörler',
      'Yerleşme Tipleri',
      'Türkiye\'de Yerleşmeler',
      'Yerleşme Fonksiyonları',
    ];
    for (var i = 0; i < cografyaUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_4_${i + 1}',
        unitId: uCografya4,
        name: cografyaUnit4Topics[i],
        order: i,
      );
    }

    const uCografya5 = 'unit_10_cografya_5';
    await _setUnit(
      firestore,
      unitId: uCografya5,
      courseId: cCografya,
      name: 'EKONOMİK FAALİYETLER VE ETKİLER',
      order: 4,
    );
    final cografyaUnit5Topics = [
      'Ekonomik Faaliyetlerin Çeşitlenmesi',
      'Ekonomik Faaliyetlerin Sınıflandırılması',
      'Gelişmişlik Durumuna Göre Ekonomik Sektörler',
      'Türkiye Ekonomisinin Sektörel Dağılımı',
    ];
    for (var i = 0; i < cografyaUnit5Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_5_${i + 1}',
        unitId: uCografya5,
        name: cografyaUnit5Topics[i],
        order: i,
      );
    }

    const uCografya6 = 'unit_10_cografya_6';
    await _setUnit(
      firestore,
      unitId: uCografya6,
      courseId: cCografya,
      name: 'AFETLER VE SÜRDÜRÜLEBİLİR ÇEVRE',
      order: 5,
    );
    final cografyaUnit6Topics = [
      'Afetlerle Mücadelede İyi Uygulamalar',
      'Afetlere Karşı Dirençli Yaşam Alanları',
      'Afetlere Dirençli Yaşam Alanları Oluşturmak',
      'Afet Bilinci ve Hazırlık',
    ];
    for (var i = 0; i < cografyaUnit6Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_6_${i + 1}',
        unitId: uCografya6,
        name: cografyaUnit6Topics[i],
        order: i,
      );
    }

    const uCografya7 = 'unit_10_cografya_7';
    await _setUnit(
      firestore,
      unitId: uCografya7,
      courseId: cCografya,
      name: 'BÖLGELER, ÜLKELER VE KÜRESEL BAĞLANTILAR',
      order: 6,
    );
    final cografyaUnit7Topics = [
      'Türk Kültürü: Mekânsal Özellikleri',
      'Genel Kültürel Özellikler',
      'Türk Dünyasının Kültürel Mirası',
    ];
    for (var i = 0; i < cografyaUnit7Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_cografya_7_${i + 1}',
        unitId: uCografya7,
        name: cografyaUnit7Topics[i],
        order: i,
      );
    }

    // Tarih
    const cTarih = 'course_10_tarih';
    await _setCourse(
      firestore,
      courseId: cTarih,
      classLevel: classLevel,
      name: 'Tarih',
    );
    const uTarih1 = 'unit_10_tarih_1';
    await _setUnit(
      firestore,
      unitId: uTarih1,
      courseId: cTarih,
      name: 'TÜRKİSTAN\'DAN TÜRKİYE\'YE (1040 - 1299)',
      order: 0,
    );
    final tarihUnit1Topics = [
      'Türkistan\'dan Türkiye\'ye Askeri Gelişmeler',
      'Türkistan\'dan Türkiye\'ye Türklerde Devlet ve Ordu Teşkilatları',
      'Türklerde Sosyoekonomik Hayat ve Şehirleşme',
      'Türk-İslam Medeniyetinde Bilim, Kültür, Eğitim ve Sanat',
    ];
    for (var i = 0; i < tarihUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tarih_1_${i + 1}',
        unitId: uTarih1,
        name: tarihUnit1Topics[i],
        order: i,
      );
    }

    const uTarih2 = 'unit_10_tarih_2';
    await _setUnit(
      firestore,
      unitId: uTarih2,
      courseId: cTarih,
      name: 'BEYLİKTEN DEVLETE OSMANLI (1299-1453)',
      order: 1,
    );
    final tarihUnit2Topics = [
      'Osmanlı Devleti\'nin Kuruluşuna Dair Görüşler',
      'Beylikten Devlete Siyasi ve Askeri Gelişmeler',
      'Osmanlı Devleti\'nde Ordu, Hukuk ve Toprak Sistemi',
      'Osmanlı Devleti\'nde İskan ve İstimalet Politikası',
      'Osmanlı Devleti\'nin İlim ve İrfan Geleneği',
    ];
    for (var i = 0; i < tarihUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tarih_2_${i + 1}',
        unitId: uTarih2,
        name: tarihUnit2Topics[i],
        order: i,
      );
    }

    const uTarih3 = 'unit_10_tarih_3';
    await _setUnit(
      firestore,
      unitId: uTarih3,
      courseId: cTarih,
      name: 'CİHAN DEVLETİ OSMANLI',
      order: 2,
    );
    final tarihUnit3Topics = [
      'Osmanlı Devleti\'nin Cihan Devleti Haline Gelmesi',
      'Osmanlı Devleti\'nin Yönetim ve Ordu Yapısında Değişim',
      'Avrupalıların Sömürgeci Politikaları',
      'Osmanlı Devleti\'nde İsyanlar',
      'Osmanlı Devleti\'nde Bilim, Kültür, Eğitim ve Sanat',
    ];
    for (var i = 0; i < tarihUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tarih_3_${i + 1}',
        unitId: uTarih3,
        name: tarihUnit3Topics[i],
        order: i,
      );
    }

    // Türk Dili ve Edebiyatı
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
      name: 'SÖZÜN EZGİSİ',
      order: 0,
    );
    final tdeUnit1Topics = [
      'Koşma-Koşuk',
      'Türkü-Ninni',
      'Masal',
      'İsim',
      'Sıfat',
      'İsim-Sıfat Tamlaması',
    ];
    for (var i = 0; i < tdeUnit1Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tde_1_${i + 1}',
        unitId: uTde1,
        name: tdeUnit1Topics[i],
        order: i,
      );
    }

    const uTde2 = 'unit_10_tde_2';
    await _setUnit(
      firestore,
      unitId: uTde2,
      courseId: cTde,
      name: 'KELİMELERİN RİTMİ',
      order: 1,
    );
    final tdeUnit2Topics = [
      'Gazel, Kaside',
      'Şarkı',
      'Saf Şiir',
      'Sohbet (Söyleşi)',
      'Zamir',
      'Edat-Bağlaç-Ünlem',
    ];
    for (var i = 0; i < tdeUnit2Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tde_2_${i + 1}',
        unitId: uTde2,
        name: tdeUnit2Topics[i],
        order: i,
      );
    }

    const uTde3 = 'unit_10_tde_3';
    await _setUnit(
      firestore,
      unitId: uTde3,
      courseId: cTde,
      name: 'DÜNDEN BUGÜNE',
      order: 2,
    );
    final tdeUnit3Topics = [
      'Destan',
      'Mesnevi-Halk Hikayesi',
      'Fabl',
      'Zarf',
    ];
    for (var i = 0; i < tdeUnit3Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tde_3_${i + 1}',
        unitId: uTde3,
        name: tdeUnit3Topics[i],
        order: i,
      );
    }

    const uTde4 = 'unit_10_tde_4';
    await _setUnit(
      firestore,
      unitId: uTde4,
      courseId: cTde,
      name: 'NESİLLERİN RUHU',
      order: 3,
    );
    final tdeUnit4Topics = [
      'Dede Korkut Hikayeleri',
      'Tanzimat-Fecriati Şiiri',
      'Servetifünun Romanı',
      'Milli Edebiyat Hikayesi',
      'Fiiller',
      'Ek Fiil',
      'Fiilde Yapı',
    ];
    for (var i = 0; i < tdeUnit4Topics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_10_tde_4_${i + 1}',
        unitId: uTde4,
        name: tdeUnit4Topics[i],
        order: i,
      );
    }
  }

  // -------------------------
  // 11. SINIF
  // -------------------------
  static Future<void> _seedGrade11(FirebaseFirestore firestore) async {
    const classLevel = '11. Sınıf';

    // Türk Dili ve Edebiyatı
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
      name: 'Konular',
      order: 0,
    );
    final tdeTopics = [
      'Edebiyat-Toplum İlişkisi',
      'Edebiyatın Sanat Akımları ile İlişkisi',
      'Yazım Kuralları',
      'Noktalama İşaretleri',
      'Cumhuriyet Döneminde (1923-1940 arası) Hikâye',
      'Cumhuriyet Döneminde (1940-1960 arası) Hikâye',
      'Cümlenin Öğeleri',
      'Tanzimat Dönemi Şiir',
      'Servetifünun Şiir',
      'Saf Şiir Anlayışına Bağlı Şiir',
      'Milli Edebiyat Döneminde Şiir',
      'Türk Dünyası Edebiyatında Şiir',
      'Makale',
      'Sohbet (Söyleşi)',
      'Fıkra (Köşe Yazısı)',
      'Roman',
      'Cumhuriyet Dönemi Roman',
      'Dünya Edebiyatında Roman',
      'Anlatım Bozukluğu',
      'Tiyatro',
      'Cumhuriyet Döneminde Tiyatro',
      'Eleştiri',
      'Mülakat',
      'Röportaj',
    ];
    for (var i = 0; i < tdeTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_tde_1_${i + 1}',
        unitId: uTde1,
        name: tdeTopics[i],
        order: i,
      );
    }

    // Matematik
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
      name: 'Konular',
      order: 0,
    );
    final matTopics = [
      'Derece - Dakika - Saniye',
      'Birim Çember',
      'Esas Ölçü',
      'İlk Üçgende Trigonometrik Oranlar',
      'Trigonometrik Fonksiyonların Tanımı',
      'Özel Açılar, İndirgeme',
      'Trigonometrik Özdeşlikler',
      'Trigonometrik Fonksiyonlarda Sıralama',
      'Kosinüs ve Sinüs Teoremi',
      'Periyot',
      'Trigonometrik Fonksiyonların Grafikleri',
      'Ters Trigonometrik Fonksiyonlar',
      'Noktanın Analitik İncelemesi',
      'Doğrunun Analitik İncelemesi',
      'Fonksiyonlarla İlgili Uygulamalar',
      'İkinci Dereceden Fonksiyonlar ve Grafikleri (Parabol)',
      'Fonksiyonların Dönüşümleri',
      'İkinci Dereceden İki Bilinmeyenli Denklem Sistemleri',
      'Eşitsizlikler',
      'Çemberin Temel Elemanları',
      'Çemberde Açı',
      'Çemberde Teğet',
      'Dairenin Çevresi ve Alanı',
      'Silindir',
      'Koni',
      'Küre',
      'Koşullu Olasılık',
      'Bağımlı-Bağımsız Olaylar Olasılığı',
      'Deneysel ve Teorik Olasılık',
    ];
    for (var i = 0; i < matTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_matematik_1_${i + 1}',
        unitId: uMat1,
        name: matTopics[i],
        order: i,
      );
    }

    // Fizik
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
      name: 'Konular',
      order: 0,
    );
    final fizikTopics = [
      'Vektörler',
      'Bağıl Hareket',
      'Newton\'un Hareket Yasaları',
      'Bir Boyutta İvmeli Hareket',
      'Serbest Düşme',
      'Hava Direnç Kuvveti',
      'Düşey Atış Hareketi',
      'Yatay Atış Hareketi',
      'Eğik Atış Hareketi',
      'İş ve Enerji',
      'Esneklik Potansiyel Enerji',
      'Mekanik Enerji',
      'Mekanik Enerjinin Korunumu',
      'İtme ve Çizgisel Momentum',
      'Çarpışmalar ve Momentum Korunumu',
      'Tork',
      'Denge',
      'Kütle ve Ağırlık Merkezi',
      'Basit Makineler',
      'Elektriksel Kuvvet',
      'Elektrik Alan',
      'Elektriksel Potansiyel',
      'Elektriksel Potansiyel ve Elektrik Alan',
      'Elektriksel Potansiyel, Enerji ve İş',
      'Düzgün Elektrik Alan',
      'Kondansatör',
      'Manyetik Alan',
      'Manyetik Kuvvet',
      'İndüksiyon Akımı',
      'Öz İndüksiyon Akımı',
      'Lorentz Kuvveti',
      'Alternatif Akım',
      'Transformatörler',
    ];
    for (var i = 0; i < fizikTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_fizik_1_${i + 1}',
        unitId: uFiz1,
        name: fizikTopics[i],
        order: i,
      );
    }

    // Kimya
    const cKimya = 'course_11_kimya';
    await _setCourse(
      firestore,
      courseId: cKimya,
      classLevel: classLevel,
      name: 'Kimya',
    );
    const uKimya1 = 'unit_11_kimya_1';
    await _setUnit(
      firestore,
      unitId: uKimya1,
      courseId: cKimya,
      name: 'Konular',
      order: 0,
    );
    final kimyaTopics = [
      'Atomun kuantum modeli ve kuantum sayıları',
      'Elektron dizilişi, grup ve periyot bulma',
      'Periyodik tablo ve periyodik değişimler',
      'Yükseltgenme basamağı',
      'Gazların özellikleri, gaz kanunları ve ideal gaz denklemi',
      'Gazların kinetiği',
      'Gazlarda kısmi basınç',
      'Gazların karşılaştırılması ve gazların yoğunluğu',
      'Gazların karıştırılması',
      'Su üstünde gaz toplanması ve denge buhar basıncı',
      'Gerçek gazlar',
      'Çözücü-çözünen etkileşimleri',
      'Derişim birimleri',
      'Koligatif özellikler',
      'Çözünürlük',
      'Endotermik-ekzotermik tepkimeler ve grafikleri',
      'Oluşum entalpileri',
      'Bağ enerjileri ve hess yasası',
      'Ortalama tepkime hızı, hız ölçümü ve çarpışma teorisi',
      'Hız bağıntısı',
      'Hıza etki eden faktörler',
      'Kademeli tepkimelerde hız ve deneysel verilerle hız',
      'Denge oluşumu ve şartları',
      'Denge sabitleri (Kc-Kp) ve hesaplamaları',
      'Dengede hess prensipleri ve denge kesri',
      'Dengeye etki eden faktörler',
      'Asit-baz özellikleri ve Konjuge asit-baz çifti',
      'Suyun oto iyonizasyonu ve PH-POH kavramı',
      'Kuvvetli asit ve bazlarda PH-POH',
      'Zayıf asit ve bazlarda PH-POH',
      'Tampon çözeltilerde PH-POH ve hidroliz',
      'Nötrleşme ve titrasyon',
      'Çözünürlük dengesi ve sabiti (Kçç)',
      'Çözünürlüğe etki eden faktörler',
      'Çözünürlüğe ortak iyon etkisi',
    ];
    for (var i = 0; i < kimyaTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_kimya_1_${i + 1}',
        unitId: uKimya1,
        name: kimyaTopics[i],
        order: i,
      );
    }

    // Biyoloji
    const cBiyo = 'course_11_biyoloji';
    await _setCourse(
      firestore,
      courseId: cBiyo,
      classLevel: classLevel,
      name: 'Biyoloji',
    );
    const uBiyo1 = 'unit_11_biyoloji_1';
    await _setUnit(
      firestore,
      unitId: uBiyo1,
      courseId: cBiyo,
      name: 'Konular',
      order: 0,
    );
    final biyoTopics = [
      'Sinir Dokusu - Nöronların Özellikleri',
      'İnsanda Sinir Sistemi',
      'Endokrin Sistem ve Hormonlar',
      'Duyu Organları',
      'Kemik Doku, Kıkırdak Doku ve İskelet Sistemi',
      'Kas Doku ve Kas Sistemi',
      'Sindirim Sistemi',
      'Kalp, Kan Dolaşımı ve Damarlar',
      'Kan Doku',
      'Lenf Sistemi ve Vücudun Savunulması',
      'Solunum Sistemi',
      'Üriner Sistemin Yapı, Görev ve İşleyişi',
      'Dişi ve Erkek Üreme Sistemi',
      'İnsanda Embriyonik Gelişim Basamakları',
      'Komünite Ekolojisi',
      'Popülasyon Ekolojisi',
    ];
    for (var i = 0; i < biyoTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_biyoloji_1_${i + 1}',
        unitId: uBiyo1,
        name: biyoTopics[i],
        order: i,
      );
    }

    // Coğrafya
    const cCografya = 'course_11_cografya';
    await _setCourse(
      firestore,
      courseId: cCografya,
      classLevel: classLevel,
      name: 'Coğrafya',
    );
    const uCografya1 = 'unit_11_cografya_1';
    await _setUnit(
      firestore,
      unitId: uCografya1,
      courseId: cCografya,
      name: 'Konular',
      order: 0,
    );
    final cografyaTopics = [
      'Biyoçeşitlilik ve Ekosistemlerin Unsurları',
      'Besin Zinciri ve Enerji Akışı',
      'Madde Döngüleri',
      'Su Ekosistemleri',
      'Ülkelerin Nüfus Politikaları',
      'Türkiye\'de Nüfus Politikaları',
      'Şehirlerin Tarihsel Gelişimi',
      'Şehirlerin Fonksiyonları',
      'Türkiye\'de Kırsal Yerleşmeler',
      'Üretim - Dağıtım ve Tüketim',
      'Doğal Kaynak ve Ekonomi İlişkisi',
      'Türkiye\'nin Ekonomi Politikaları',
      'Türkiye\'de Tarım ve Hayvancılık',
      'Türkiye\'de Madenler',
      'Türkiye\'de Enerji Kaynakları',
      'Türkiye\'de Sanayi',
      'İlk Kültür Merkezleri',
      'Kültür Bölgeleri ve Türk Kültürü',
      'Küresel Ticaret',
      'Turizm',
      'Sanayileşme Süreci',
      'Tarım - Ekonomi İlişkisi',
      'Uluslararası Örgütler',
      'Çevre Sorunları',
      'Doğal Kaynak Kullanımının Çevresel Etkileri',
      'Beşeri Faaliyetlerin Çevresel Etkileri',
    ];
    for (var i = 0; i < cografyaTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_cografya_1_${i + 1}',
        unitId: uCografya1,
        name: cografyaTopics[i],
        order: i,
      );
    }

    // Tarih
    const cTarih = 'course_11_tarih';
    await _setCourse(
      firestore,
      courseId: cTarih,
      classLevel: classLevel,
      name: 'Tarih',
    );
    const uTarih1 = 'unit_11_tarih_1';
    await _setUnit(
      firestore,
      unitId: uTarih1,
      courseId: cTarih,
      name: 'Konular',
      order: 0,
    );
    final tarihTopics = [
      'XVII. Yüzyıl Siyasi Ortamında Osmanlı Devleti',
      'Açık Sularda Güç Mücadelesi',
      'XVIII. Yüzyıl Siyasi Ortamında Osmanlı Devleti',
      'Yeni Çağ Avrupasında Meydana Gelen Gelişmeler',
      'Westphalia Barışından Modern Devletler Hukukuna',
      'Osmanlı Sosyo-Ekonomik Yapısında Değişiklikler',
      'Osmanlı Devletinde Çözülmeye Karşı Önlemler',
      'Avrupa\'da Devrimler ve Değişimler',
      'Klasik Üretim ve Endüstriyel Üretim',
      'Osmanlı Devletinde Modern Ordu Teşkilatı ve Yurttaş Askerliği',
      'Ulusallaşmanın ve Endüstrileşmenin Sosyal Etkileri',
      'Osmanlı Devletinin Siyasi Varlığına Yönelik Tehditler',
      'Kuzeyden Gelen Tehlike Rusya',
      'Osmanlı Devletinde Demokratikleşme Süreci ve Darbeler',
      'Osmanlı Devletinde Endüstriyel Üretime Geçiş',
      'Osmanlı Devletinde Ekonomiyi Düzeltme Çabaları',
      'Ulus Devlete Geçişte Demografik Değişim',
      'Modernleşme ve Sosyal Yaşamda Değişim',
    ];
    for (var i = 0; i < tarihTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_11_tarih_1_${i + 1}',
        unitId: uTarih1,
        name: tarihTopics[i],
        order: i,
      );
    }
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

  // -------------------------
  // TYT (11, 12, Mezun odak dersleri)
  // -------------------------
  static Future<void> _seedTYT(FirebaseFirestore firestore) async {
    const classLevel = 'TYT';
    final tytCourses = [
      ['course_tyt_turkce', 'Türkçe'],
      ['course_tyt_matematik', 'Matematik'],
      ['course_tyt_fizik', 'Fizik'],
      ['course_tyt_kimya', 'Kimya'],
      ['course_tyt_biyoloji', 'Biyoloji'],
      ['course_tyt_geometri', 'Geometri'],
      ['course_tyt_felsefe', 'Felsefe'],
      ['course_tyt_cografya', 'Coğrafya'],
      ['course_tyt_tarih', 'Tarih'],
      ['course_tyt_din', 'Din Kültürü'],
    ];
    final Map<String, List<String>> tytTopicsByCourseId = {
      // 11. sınıf Türk Dili ve Edebiyatı konularının TYT Türkçe için aynen kullanımı
      'course_tyt_turkce': [
        'Edebiyat-Toplum İlişkisi',
        'Edebiyatın Sanat Akımları ile İlişkisi',
        'Yazım Kuralları',
        'Noktalama İşaretleri',
        'Cumhuriyet Döneminde (1923-1940 arası) Hikâye',
        'Cumhuriyet Döneminde (1940-1960 arası) Hikâye',
        'Cümlenin Öğeleri',
        'Tanzimat Dönemi Şiir',
        'Servetifünun Şiir',
        'Saf Şiir Anlayışına Bağlı Şiir',
        'Milli Edebiyat Döneminde Şiir',
        'Türk Dünyası Edebiyatında Şiir',
        'Makale',
        'Sohbet (Söyleşi)',
        'Fıkra (Köşe Yazısı)',
        'Roman',
        'Cumhuriyet Dönemi Roman',
        'Dünya Edebiyatında Roman',
        'Anlatım Bozukluğu',
        'Tiyatro',
        'Cumhuriyet Döneminde Tiyatro',
        'Eleştiri',
        'Mülakat',
        'Röportaj',
      ],
      // 11. sınıf Matematik konuları → TYT Matematik
      'course_tyt_matematik': [
        'Derece - Dakika - Saniye',
        'Birim Çember',
        'Esas Ölçü',
        'İlk Üçgende Trigonometrik Oranlar',
        'Trigonometrik Fonksiyonların Tanımı',
        'Özel Açılar, İndirgeme',
        'Trigonometrik Özdeşlikler',
        'Trigonometrik Fonksiyonlarda Sıralama',
        'Kosinüs ve Sinüs Teoremi',
        'Periyot',
        'Trigonometrik Fonksiyonların Grafikleri',
        'Ters Trigonometrik Fonksiyonlar',
        'Noktanın Analitik İncelemesi',
        'Doğrunun Analitik İncelemesi',
        'Fonksiyonlarla İlgili Uygulamalar',
        'İkinci Dereceden Fonksiyonlar ve Grafikleri (Parabol)',
        'Fonksiyonların Dönüşümleri',
        'İkinci Dereceden İki Bilinmeyenli Denklem Sistemleri',
        'Eşitsizlikler',
        'Çemberin Temel Elemanları',
        'Çemberde Açı',
        'Çemberde Teğet',
        'Dairenin Çevresi ve Alanı',
        'Silindir',
        'Koni',
        'Küre',
        'Koşullu Olasılık',
        'Bağımlı-Bağımsız Olaylar Olasılığı',
        'Deneysel ve Teorik Olasılık',
      ],
      // 11. sınıf Fizik konuları → TYT Fizik
      'course_tyt_fizik': [
        'Vektörler',
        'Bağıl Hareket',
        'Newton\'un Hareket Yasaları',
        'Bir Boyutta İvmeli Hareket',
        'Serbest Düşme',
        'Hava Direnç Kuvveti',
        'Düşey Atış Hareketi',
        'Yatay Atış Hareketi',
        'Eğik Atış Hareketi',
        'İş ve Enerji',
        'Esneklik Potansiyel Enerji',
        'Mekanik Enerji',
        'Mekanik Enerjinin Korunumu',
        'İtme ve Çizgisel Momentum',
        'Çarpışmalar ve Momentum Korunumu',
        'Tork',
        'Denge',
        'Kütle ve Ağırlık Merkezi',
        'Basit Makineler',
        'Elektriksel Kuvvet',
        'Elektrik Alan',
        'Elektriksel Potansiyel',
        'Elektriksel Potansiyel ve Elektrik Alan',
        'Elektriksel Potansiyel, Enerji ve İş',
        'Düzgün Elektrik Alan',
        'Kondansatör',
        'Manyetik Alan',
        'Manyetik Kuvvet',
        'İndüksiyon Akımı',
        'Öz İndüksiyon Akımı',
        'Lorentz Kuvveti',
        'Alternatif Akım',
        'Transformatörler',
      ],
      // 11. sınıf Kimya konuları → TYT Kimya
      'course_tyt_kimya': [
        'Atomun kuantum modeli ve kuantum sayıları',
        'Elektron dizilişi, grup ve periyot bulma',
        'Periyodik tablo ve periyodik değişimler',
        'Yükseltgenme basamağı',
        'Gazların özellikleri, gaz kanunları ve ideal gaz denklemi',
        'Gazların kinetiği',
        'Gazlarda kısmi basınç',
        'Gazların karşılaştırılması ve gazların yoğunluğu',
        'Gazların karıştırılması',
        'Su üstünde gaz toplanması ve denge buhar basıncı',
        'Gerçek gazlar',
        'Çözücü-çözünen etkileşimleri',
        'Derişim birimleri',
        'Koligatif özellikler',
        'Çözünürlük',
        'Endotermik-ekzotermik tepkimeler ve grafikleri',
        'Oluşum entalpileri',
        'Bağ enerjileri ve hess yasası',
        'Ortalama tepkime hızı, hız ölçümü ve çarpışma teorisi',
        'Hız bağıntısı',
        'Hıza etki eden faktörler',
        'Kademeli tepkimelerde hız ve deneysel verilerle hız',
        'Denge oluşumu ve şartları',
        'Denge sabitleri (Kc-Kp) ve hesaplamaları',
        'Dengede hess prensipleri ve denge kesri',
        'Dengeye etki eden faktörler',
        'Asit-baz özellikleri ve Konjuge asit-baz çifti',
        'Suyun oto iyonizasyonu ve PH-POH kavramı',
        'Kuvvetli asit ve bazlarda PH-POH',
        'Zayıf asit ve bazlarda PH-POH',
        'Tampon çözeltilerde PH-POH ve hidroliz',
        'Nötrleşme ve titrasyon',
        'Çözünürlük dengesi ve sabiti (Kçç)',
        'Çözünürlüğe etki eden faktörler',
        'Çözünürlüğe ortak iyon etkisi',
      ],
      // 11. sınıf Biyoloji konuları → TYT Biyoloji
      'course_tyt_biyoloji': [
        'Sinir Dokusu - Nöronların Özellikleri',
        'İnsanda Sinir Sistemi',
        'Endokrin Sistem ve Hormonlar',
        'Duyu Organları',
        'Destek ve Hareket Sistemi',
        'Sindirim Sistemi ve Bozuklukları',
        'Solunum Sistemi ve Bozuklukları',
        'Dolaşım Sistemi ve Bozuklukları',
        'Bağışıklık Sistemi',
        'Boşaltım Sistemi ve Bozuklukları',
        'Üriner Sistem',
        'Üreme Sistemi ve Gelişim',
        'Komünite Ekolojisi',
        'Popülasyon Ekolojisi',
      ],
      // 11. sınıf Coğrafya → TYT Coğrafya
      'course_tyt_cografya': [
        'Türkiye\'nin Yer Şekilleri',
        'Türkiye\'de İklim ve Bitki Örtüsü',
        'Türkiye\'de Nüfus ve Yerleşme',
        'Türkiye\'nin Ekonomik Faaliyetleri',
        'Türkiye\'de Ulaşım ve Ticaret',
        'Türkiye\'de Çevre ve Toplum',
      ],
      // 11. sınıf Tarih → TYT Tarih (özet başlıklar)
      'course_tyt_tarih': [
        'XVII. Yüzyıl Siyasi Ortamında Osmanlı Devleti',
        'XVIII. Yüzyıl Siyasi Ortamında Osmanlı Devleti',
        'Yeni Çağ Avrupasında Meydana Gelen Gelişmeler',
        'Osmanlı Sosyo-Ekonomik Yapısında Değişiklikler',
        'Osmanlı Devletinde Demokratikleşme Süreci',
        'Avrupa\'da Devrimler ve Değişimler',
        'Ulus Devlete Geçişte Demografik Değişim',
        'Modernleşme ve Sosyal Yaşamda Değişim',
      ],
    };

    for (var i = 0; i < tytCourses.length; i++) {
      final courseId = tytCourses[i][0];
      final name = tytCourses[i][1];
      await _setCourse(
        firestore,
        courseId: courseId,
        classLevel: classLevel,
        name: name,
      );
      final unitId =
          'unit_tyt_${courseId.replaceFirst('course_tyt_', '')}_1';
      await _setUnit(
        firestore,
        unitId: unitId,
        courseId: courseId,
        name: 'TYT Konuları',
        order: 0,
      );
      final topics = tytTopicsByCourseId[courseId];
      if (topics == null || topics.isEmpty) {
        await _setTopic(
          firestore,
          topicId: 'topic_tyt_${courseId.replaceFirst('course_tyt_', '')}_1_1',
          unitId: unitId,
          name: '$name TYT konuları',
          order: 0,
        );
      } else {
        for (var t = 0; t < topics.length; t++) {
          await _setTopic(
            firestore,
            topicId:
                'topic_tyt_${courseId.replaceFirst('course_tyt_', '')}_1_${t + 1}',
            unitId: unitId,
            name: topics[t],
            order: t,
          );
        }
      }
    }
  }

  // -------------------------
  // AYT (12, Mezun odak dersleri)
  // -------------------------
  static Future<void> _seedAYT(FirebaseFirestore firestore) async {
    const classLevel = 'AYT';
    final aytCourses = [
      ['course_ayt_sosyoloji', 'Sosyoloji'],
      ['course_ayt_psikoloji', 'Psikoloji'],
      ['course_ayt_felsefe', 'Felsefe'],
      ['course_ayt_tde', 'Türk Dili ve Edebiyatı'],
      ['course_ayt_cografya', 'Coğrafya'],
      ['course_ayt_tarih', 'Tarih'],
      ['course_ayt_kimya', 'Kimya'],
      ['course_ayt_biyoloji', 'Biyoloji'],
      ['course_ayt_mantik', 'Mantık'],
      ['course_ayt_matematik', 'Matematik'],
      ['course_ayt_fizik', 'Fizik'],
      ['course_ayt_geometri', 'Geometri'],
    ];
    final Map<String, List<String>> aytTopicsByCourseId = {
      'course_ayt_sosyoloji': [
        'Sosyoloji Giriş',
        'Birey Toplum İlişkisi',
        'Toplum Yapısı',
        'Toplumda Değişme ve Gelişme',
        'Toplum ile Kültür',
        'Toplumun Kurumları',
      ],
      'course_ayt_psikoloji': [
        'Psikoloji Giriş',
        'Psikoloji Temel Süreçleri',
        'Öğrenme, Bellek ve Düşünme',
        'Ruh Sağlığı Temelleri',
      ],
      'course_ayt_mantik': [
        'Mantık Giriş',
        'Klasik Mantık',
        'Mantık ile Dil',
        'Sembolik Mantık',
      ],
      'course_ayt_felsefe': [
        'Felsefeyi Tanıma',
        'Bilgi Felsefesi',
        'Varlık Felsefesi',
        'Ahlak Felsefesi',
        'Sanat Felsefesi',
        'Din Felsefesi',
        'Siyaset Felsefesi',
        'Bilim Felsefesi',
        'İlk Çağ Felsefesi',
        'MÖ 6. Yüzyıl-MS. Yüzyıl Felsefesi',
        'MS 2. Yüzyıl-MS 25. Yüzyıl Felsefesi',
        '15. Yüzyıl-17. Yüzyıl Felsefesi',
        '18. Yüzyıl-19. Yüzyıl Felsefesi',
        '20. Yüzyıl Felsefesi',
      ],
      'course_ayt_tde': [
        'Güzel Sanatlar ve Edebiyat',
        'Şiirde Ahenk (Ölçü-Uyak-Redif)',
        'Şiirde Yapı ve Türleri',
        'Edebi Sanatlar (Söz Sanatları)',
        'Düzyazı Türleri',
        'Edebi Akımlar',
        'İslamiyet Öncesi Sözlü Edebiyat',
        'İslamiyet Öncesi Yazılı Edebiyat',
        'İslamiyet Etkisindeki Geçiş Dönemi',
        'Halk Edebiyatı',
        'Divan Edebiyatı',
        'Tanzimat Dönemi',
        'Servet-i Fünun Dönemi',
        'Fecr-i Ati Topluluğu',
        'Milli Edebiyat Dönemi',
        'Cumhuriyet Dönemi - Şiir',
        'Cumhuriyet Dönemi - Hikaye - Roman',
        'Cumhuriyet Dönemi - Tiyatro',
        'Cumhuriyet Dönemi - Öğretici Metinler',
        'Türk Dünyası Edebiyatı - Dünya Edebiyatı',
      ],
      'course_ayt_cografya': [
        'Biyoçeşitlilik',
        'Ekosistem, Enerji Akışı ve Madde Döngüleri',
        'Su Ekosistemleri',
        'Doğadaki Ekstrem Olaylar',
        'Doğa ve Değişim',
        'Nüfus Politikaları',
        'Türkiye\'nin Nüfus Projeksiyonları',
        'Şehirler ve Etki Alanları',
        'Ekonomik Faaliyet Türleri',
        'Ekonomik Faaliyetlerin Sosyal ve Kültürel Etkileri',
        'Doğal Kaynaklar ve Ekonomi',
        'Türkiye Ekonomisi ve Ekonomik Politikalar',
        'Medeniyetler Merkezi Anadolu',
        'Türkiye\'de Arazi Kullanımı',
        'Türkiye\'de Tarım',
        'Türkiye\'de Hayvancılık',
        'Türkiye\'de Madenler ve Enerji Kaynakları',
        'Türkiye\'de Sanayi',
        'Türkiye\'de Ulaşım',
        'Türkiye\'de Ticaret',
        'Türkiye\'de Turizm',
        'Türkiye\'nin Bölgesel Kalkınma Projeleri',
        'Türkiye\'de Bölge Sınıflandırması',
        'Türkiye\'nin Coğrafi Konumu ve Jeopolitiği',
        'Coğrafi Keşifler ve Sömürgecilik',
        'İlk Kültür Merkezleri',
        'Kültür Bölgelerinin Oluşumu ve Türk Kültürü',
        'Küresel Ticaret ve Turizm',
        'Ülkelerin Gelişmişlik Düzeyi ve Doğal Kaynak Potansiyelleri',
        'Gelişmiş ve Gelişmekte Olan Ülkeler',
        'Enerji Taşımacılığı',
        'Uluslararası Örgütler',
        'Çatışma Bölgeleri',
        'Doğal Çevrenin Sınırlılığı',
        'Doğal Kaynak Kullanımının Çevresel Etkileri',
        'Arazi Kullanımının Çevresel Etkileri',
        'Küresel Çevre Sorunları',
        'Doğal Kaynakların Sürdürülebilir Kullanımı',
      ],
      'course_ayt_tarih': [
        'Tarih ve Zaman',
        'İnsanlığın İlk Dönemleri',
        'Orta Çağ\'da Dünya',
        'İlk ve Orta Çağlarda Türk Dünyası',
        'İslam Medeniyetinin Doğuşu',
        'Türklerin İslamiyet\'i Kabulü ve İlk Türk İslam Devletleri',
        'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi',
        'Beylikten Devlete Osmanlı Siyaseti (1302-1453)',
        'Devletleşme Sürecinde Savaşçılar ve Askerler',
        'Beylikten Devlete Osmanlı Medeniyeti',
        'Dünya Gücü Osmanlı (1453-1595)',
        'Sultan ve Osmanlı Merkez Teşkilatı',
        'Klasik Çağda Osmanlı Toplum Düzeni',
        'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti (1595-1774)',
        'Değişim Çağında Avrupa ve Osmanlı',
        'Devrimler Çağında Değişen Devlet-Toplum İlişkileri',
        'Uluslararası İlişkilerde Denge Stratejisi (1774-1914)',
        'XIX. ve XX. Yüzyılda Değişen Sosyo-Ekonomik Hayat',
        'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya',
        'Milli Mücadele\'ye Hazırlık Dönemi',
        'Milli Mücadele Dönemi',
        'Atatürkçülük ve Türk İnkılabı',
        'İki Savaş Arası Dönemde Türkiye ve Dünya',
        'II. Dünya Savaşı Sürecinde Türkiye ve Dünya',
        'II. Dünya Savaşı',
        'II. Dünya Savaşı Sonrasında Türkiye ve Dünya',
        'Soğuk Savaş Dönemi',
        'Yumuşama Dönemi ve Sonrası',
        'Toplumsal Devrim Çağında Dünya ve Türkiye',
        'XXI. Yüzyılın Eşiğinde Türkiye ve Dünya',
        'Küreselleşen Dünya',
      ],
      'course_ayt_matematik': [
        'Polinomlar',
        'Çarpanlara Ayırma',
        'İkinci Dereceden Denklemler',
        'Fonksiyonların Dönüşümleri, Ötelenmeleri, Simetri',
        'Parabol',
        'İkinci Dereceden Eşitsizlikler',
        'Toplama Çarpma Yoluyla Seyma',
        'Permütasyon',
        'Kombinasyon',
        'Binom',
        'Olasılık',
        'Trigonometri',
        'Logaritma',
        'Diziler',
        'Limit - Süreklilik',
        'Türev',
        'İntegral',
      ],
      'course_ayt_geometri': [
        'Temel Geometrik Kavramlar',
        'Doğruda Açılar',
        'Üçgende Açılar',
        'Açı - Kenar Bağıntıları',
        'Dik Üçgen',
        'İkizkenar Üçgen',
        'Eşkenar Üçgen',
        'Üçgende Açıortay',
        'Üçgende Kenarortay',
        'Üçgende Merkezler',
        'Üçgenin Eşliği ve Benzerliği',
        'Üçgende Alan',
        'Çokgenler',
        'Genel Dörtgenler',
        'Deltoid',
        'Yamuk',
        'Paralelkenar',
        'Eşkenar Dörtgen',
        'Dikdörtgen',
        'Kare',
        'Noktanın Analitik İncelemesi',
        'Doğrunun Analitik İncelemesi',
        'Çemberde Açı',
        'Çemberde Uzunluk',
        'Dairede Alan',
        'Çemberin Analitik İncelemesi',
        'Dik Prizmalar',
        'Dik Piramitler',
        'Silindir',
        'Koni',
        'Küre',
        'Dönüşüm Geometrisi',
      ],
      'course_ayt_fizik': [
        'Vektör ve Kuvvet',
        'Bağıl Hareket',
        'Newton\'un Hareket Yasaları',
        'Doğrusal Hareket',
        'Yeryüzünde Hareket',
        'İş ve Enerji',
        'İtme ve Momentum',
        'Kuvvet - Tork - Denge',
        'Ağırlık Merkezi',
        'Basit Makineler',
        'Düzgün Çembersel Hareket',
        'Dönme Kinetik Enerjisi- Açısal Momentum',
        'Genel Çekim Kanunu ve Kepler Kanunları',
        'Basit Harmonik Hareket',
        'Elektriksel Kuvvet',
        'Elektriksel Alan',
        'Elektriksel Potansiyel Enerji',
        'Elektriksel Potansiyel - Elektriksel İş',
        'Düzgün Elektrik Alan ve Paralel Levhalar',
        'Sığaçlar',
        'Manyetik Alan',
        'Manyetik Kuvvet',
        'Elektromanyetik İndüksiyon',
        'Alternatif Akım ve Transformatörler',
        'Su Dalgalarında Kırınım - Girişim',
        'Işık Teorileri',
        'Elektromanyetik Dalgalar',
        'Atom Modelleri',
        'Atomaltı Parçacıklar',
        'Radyoaktivite',
        'Özel Görelilik',
        'Siyah Cisim Işıması - Fotoelektrik Olay',
        'Modern Fiziğin Uygulamaları - Görüntüleme Teknolojisi',
      ],
      'course_ayt_biyoloji': [
        'Sinir Sistemi',
        'Endokrin Sistem',
        'Duyu Organları',
        'Destek ve Hareket Sistemi',
        'Sindirim Sistemi',
        'Dolaşım Sistemleri ve Vücut Savunmaları',
        'Solunum Sistemi',
        'Üriner Sistem',
        'Üreme Sistemi ve Embriyonik Gelişim',
        'Komünite Ekolojisi',
        'Popülasyon Ekolojisi',
        'Nükleik Asitler',
        'Genetik Şifre ve Protein Sentezi',
        'Genellik Mühendisliği ve Biyoteknoloji',
        'Fotosentez ve Kemosentez',
        'Hücresel Solunum',
        'Bitkisel Dokular ve Organlar',
        'Bitkilerde Hormonlar ve Bitkilerde Hareket',
        'Bitkilerde Beslenme ve Madde Taşınması',
        'Bitkilerde Eşeyli Üreme ve Çimlenme',
        'Canlılar ve Çevre',
      ],
      'course_ayt_kimya': [
        'Atomun kuantum modeli ve kuantum sayıları',
        'Elektron dizilişi, grup ve periyot bulma',
        'Periyodik tablo ve periyodik değişimler',
        'Yükseltgenme basamağı',
        'Gazların özellikleri, gaz kanunları ve ideal gaz denklemi',
        'Gazların kinetiği',
        'Gazlarda kısmi basınç',
        'Gazların karşılaştırılması ve gazların yoğunluğu',
        'Gazların karıştırılması',
        'Su üstünde gaz toplanması ve denge buhar basıncı',
        'Gerçek gazlar',
        'Çözelti-çözünen etkileşimleri',
        'Derşim birimleri',
        'Koligatif özellikler',
        'Çözünürlük',
        'Endotermik-ekzotermik tepkimeler ve grafikleri',
        'Oluşum entalpileri',
        'Bağ enerjileri ve Hess yasası',
        'Ortalama tepkime hızı, hız ölçümü ve çarpışma teorisi',
        'Hız bağıntısı',
        'Hıza etki eden faktörler',
        'Kademeli tepkimelerde hız ve deneysel verilerle hız',
        'Denge oluşumu ve şartları',
        'Denge sabitleri (Kc-Kp) ve hesaplamaları',
        'Dengede Hess prensipleri ve denge kesri',
        'Dengeye etki eden faktörler',
        'Denge denklemleri',
        'Asit-baz özellikleri ve konjuge asit-baz çifti',
        'Suyun otoiyonizasyonu ve pH-pOH kavramı',
        'Kuvvetli asit ve bazlarda pH-pOH',
        'Zayıf asit ve bazlarda pH-pOH',
        'Tampon çözeltilerde pH-pOH ve hidroliz',
        'Nötrleşme ve titrasyon',
        'Çözünürlük dengesi ve sabiti (Kçç)',
        'Çözünürlüğe etki eden faktörler',
        'Çözünürlüğe ortak iyon etkisi',
        'İndirgenme-yükseltgenme tepkimeleri (Redoks)',
        'Aktiflik ve aşınma',
        'Piller ve pil geriliminin hesaplanması',
        'Pil potansiyeline etki eden faktörler',
        'Elektroliz',
        'Faraday yasaları ve hesaplamalar',
        'Karbon kimyasına giriş ve Lewis yapıları',
        'Hibritleşme ve molekül geometrisi (VSEPR)',
        'Hidrokarbonların genel özellikleri',
        'Alkanlar',
        'Alkenler',
        'Alkinler',
        'Aromatik bileşikler',
        'Alkoller',
        'Eterler',
        'Aldehitler',
        'Ketonlar',
        'Karboksilik asitler',
        'Esterler',
        'Enerji kaynakları ve bilimsel gelişmeler',
      ],
    };
    for (var i = 0; i < aytCourses.length; i++) {
      final courseId = aytCourses[i][0];
      final name = aytCourses[i][1];
      await _setCourse(firestore, courseId: courseId, classLevel: classLevel, name: name);
      final unitId = 'unit_ayt_${courseId.replaceFirst('course_ayt_', '')}_1';
      await _setUnit(firestore, unitId: unitId, courseId: courseId, name: 'AYT Konuları', order: 0);
      final topics = aytTopicsByCourseId[courseId];
      if (topics == null || topics.isEmpty) {
        await _setTopic(
          firestore,
          topicId: 'topic_ayt_${courseId.replaceFirst('course_ayt_', '')}_1_1',
          unitId: unitId,
          name: '$name AYT konuları',
          order: 0,
        );
      } else {
        for (var t = 0; t < topics.length; t++) {
          await _setTopic(
            firestore,
            topicId: 'topic_ayt_${courseId.replaceFirst('course_ayt_', '')}_1_${t + 1}',
            unitId: unitId,
            name: topics[t],
            order: t,
          );
        }
      }
    }
  }

  // -------------------------
  // YDS (12, Mezun odak dersleri - Dil)
  // -------------------------
  static Future<void> _seedYDS(FirebaseFirestore firestore) async {
    const classLevel = 'YDS';
    const courseId = 'course_yds_dil';
    await _setCourse(firestore, courseId: courseId, classLevel: classLevel, name: 'Yabancı Dil (YDS)');
    const unitId = 'unit_yds_dil_1';
    await _setUnit(firestore, unitId: unitId, courseId: courseId, name: 'YDS Konuları', order: 0);
    final ydsTopics = [
      'Kelime - Phrasal Verb',
      'Tense - Preposition - Dilbilgisi',
      'Cloze Test',
      'Cümle Tamamlama',
      'Çeviri',
      'Paragraf',
      'Diyalog Tamamlama',
      'Yakın Anlamlı Cümle',
      'Paragraf Tamamlama',
      'Anlatım Bütünlüğünü Bozan Cümle',
    ];
    for (var i = 0; i < ydsTopics.length; i++) {
      await _setTopic(
        firestore,
        topicId: 'topic_yds_dil_1_${i + 1}',
        unitId: unitId,
        name: ydsTopics[i],
        order: i,
      );
    }
  }
}
