// Test للـ Smart Assistant ChatBubble:
// - دالة _linkify: تحويل URLs إلى Markdown links
// - _linkify: لا تُغير روابط Markdown موجودة مسبقاً
// - _linkify: تتعامل مع www. بشكل صحيح
// - _linkify: لا تُغير النص العادي

// استخراج منطق _linkify في دالة مستقلة قابلة للـ test
// (بدون الحاجة لـ Widget أو Flutter context)

import 'package:flutter_test/flutter_test.dart';

// نفس المنطق الموجود في chat_bubble.dart
String linkify(String text) {
  final RegExp urlRegExp = RegExp(
    r'(?<!\]\()(https?:\/\/[^\s\)]+|www\.[^\s\)]+)',
    caseSensitive: false,
  );
  return text.replaceAllMapped(urlRegExp, (match) {
    final url = match.group(1)!;
    final href = url.startsWith('www.') ? 'https://$url' : url;
    return '[$url]($href)';
  });
}

void main() {
  group('ChatBubble._linkify — تحويل روابط URL', () {
    // ────────────────────────────────────────────────
    // URLs خام → Markdown links
    // ────────────────────────────────────────────────
    test('يحول https:// إلى markdown link', () {
      const input = 'قم بزيارة https://edl.moi.gov.eg للتسجيل';
      final result = linkify(input);
      expect(result, contains('[https://edl.moi.gov.eg](https://edl.moi.gov.eg)'));
    });

    test('يحول http:// إلى markdown link', () {
      const input = 'الرابط: http://example.com';
      final result = linkify(input);
      expect(result, contains('[http://example.com](http://example.com)'));
    });

    test('يحول www. إلى https:// markdown link', () {
      const input = 'الموقع: www.moi.gov.eg';
      final result = linkify(input);
      expect(result, contains('[www.moi.gov.eg](https://www.moi.gov.eg)'));
    });

    test('يحول رابطاً في نهاية الجملة', () {
      const input = 'للمزيد: https://traffic.gov.eg';
      final result = linkify(input);
      expect(result, contains('[https://traffic.gov.eg](https://traffic.gov.eg)'));
    });

    test('يحول رابطاً في منتصف النص', () {
      const input = 'أولاً اذهب لـ https://portal.gov.eg وسجل بياناتك';
      final result = linkify(input);
      expect(result, contains('[https://portal.gov.eg](https://portal.gov.eg)'));
      expect(result, contains('أولاً اذهب لـ'));
      expect(result, contains('وسجل بياناتك'));
    });

    test('يحول أكثر من رابط في نفس النص', () {
      const input = 'الموقع https://a.com أو https://b.com';
      final result = linkify(input);
      expect(result, contains('[https://a.com](https://a.com)'));
      expect(result, contains('[https://b.com](https://b.com)'));
    });

    // ────────────────────────────────────────────────
    // روابط Markdown موجودة → لا تُعدَّل
    // ────────────────────────────────────────────────
    test('لا يُعدل روابط Markdown الموجودة مسبقاً', () {
      const input = '[اضغط هنا](https://edl.moi.gov.eg)';
      final result = linkify(input);
      // يجب أن يبقى كما هو بدون تداخل
      expect(result, equals(input));
    });

    test('لا يُعدل الرابط المضمَّن في نص Markdown complex', () {
      const input = 'انتقل لـ [البوابة](https://portal.gov.eg) للتسجيل';
      final result = linkify(input);
      expect(result, equals(input));
    });

    // ────────────────────────────────────────────────
    // نص عادي → لا يتغير
    // ────────────────────────────────────────────────
    test('نص عادي بدون روابط لا يتغير', () {
      const input = 'مرحباً بك في نظام المرور الموحد';
      final result = linkify(input);
      expect(result, equals(input));
    });

    test('نص عربي فقط لا يتغير', () {
      const input = 'يمكنك تجديد رخصتك عبر التطبيق مباشرة';
      final result = linkify(input);
      expect(result, equals(input));
    });

    test('نص فارغ لا يتغير', () {
      const input = '';
      final result = linkify(input);
      expect(result, equals(''));
    });

    test('نص بأرقام فقط لا يتغير', () {
      const input = '12345 67890';
      final result = linkify(input);
      expect(result, equals(input));
    });

    // ────────────────────────────────────────────────
    // URLs مع query params
    // ────────────────────────────────────────────────
    test('يحول URL مع query parameters', () {
      const input = 'https://example.com/search?q=رخصة&type=driving';
      final result = linkify(input);
      expect(result, startsWith('['));
      expect(result, contains('(https://example.com/search'));
    });

    // ────────────────────────────────────────────────
    // Markdown معقد — العناوين والقوائم لا تتأثر
    // ────────────────────────────────────────────────
    test('Markdown bold مع رابط داخلي لا يتأثر', () {
      const input = '**قم بزيارة [الموقع](https://gov.eg)**';
      final result = linkify(input);
      expect(result, equals(input));
    });

    test('قائمة نقطية مع رابط خام تُحوَّل صح', () {
      const input = '- زر https://edl.moi.gov.eg\n- أو اتصل بنا';
      final result = linkify(input);
      expect(result, contains('[https://edl.moi.gov.eg]'));
      expect(result, contains('- أو اتصل بنا'));
    });
  });
}
