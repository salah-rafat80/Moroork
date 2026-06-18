# 🧪 Traffic App — Test Suite

## نتائج الفحص
```
✅ 132 tests — All Passed في 4 ثواني
```

## هيكل الـ Tests

```
test/
├── unit/
│   ├── order_model_test.dart           ← 20 test
│   ├── order_details_helper_test.dart  ← 44 test
│   ├── app_colors_theme_test.dart      ← 32 test
│   ├── auth_cubit_test.dart            ← 23 test
│   ├── my_orders_cubit_test.dart       ← 16 test
│   └── chat_linkify_test.dart          ← 17 test
```

## تشغيل الـ Tests

```bash
# كل الـ unit tests
flutter test test/unit/

# ملف محدد
flutter test test/unit/order_model_test.dart

# مع output مفصل
flutter test test/unit/ --reporter=expanded
```

---

## ما يختبره كل ملف

### 1. `order_model_test.dart` — نموذج البيانات
| الـ Test | ما يختبره |
|---------|---------|
| `fromJson` مع JSON فارغ | القيم الافتراضية صحيحة |
| `fromJson` مع JSON كامل | الحقول تُفسَّر صح |
| `OrderFees.fromJson` | تحويل null → 0.0، و int → double |
| `OrderDelivery.fromJson` | يقبل null ويحول أي نوع لـ String |
| `_parseStatus` × 9 حالات | تحويل statusLabel العربي والإنجليزي |

### 2. `order_details_helper_test.dart` — منطق الأزرار والفشل
| الـ Group | عدد | ما يختبره |
|---------|-----|---------|
| `hasMedicalFailure` | 5 | الكشف طبي → stepCode + label |
| `hasPracticalFailure` | 4 | اختبار القيادة → stepCodes متعددة |
| `hasTechnicalFailure` | 4 | الفحص الفني → stepCode + label |
| `isOrderFailed` | 6 | الفشل الكامل وحالات النجاح |
| `showFinalizeButton` | 9 | متى يظهر/يختفي زر "استكمال" |
| `getButtonLabel` | 12 | النص الصحيح لكل stepCode |

### 3. `app_colors_theme_test.dart` — الألوان والثيم
| الـ Group | ما يختبره |
|---------|---------|
| قيم ثابتة | `white`, `black`, `transparent`, `primary` |
| `isDarkMode switching` | 12 لون يتغير صح بين Light/Dark |
| WCAG contrast | نسبة تباين ≥ 4.5 للـ AA accessibility |
| `ThemeCubit` states | Initial → Dark → Light → System |
| `MaterialApp Brightness` | widget test للتحقق من تطبيق الثيم |

**تشمل هذه الـ tests الألوان التالية:**
- `background` / `textPrimary` / `border`
- `whiteBg` / `cardBg` / `charcoal`
- `chatUserBubbleStart` / `primary` (brand)
- WCAG AA للـ text على background

### 4. `auth_cubit_test.dart` — منطق المصادقة
| الـ Group | عدد | ما يختبره |
|---------|-----|---------|
| login نجاح | 4 | مواطن/موظف، جلب الرخص، أدوار متعددة |
| التحقق من الدور | 4 | CITIZEN في STAFF → فشل، DOCTOR/EXAMINATOR → نجاح |
| login فشل | 1 | رسالة الخطأ من السيرفر |
| `register` | 2 | نجاح وفشل مع رسالة |
| `verifyOtp` | 2 | OTP صحيح وخاطئ |
| `checkAuthStatus` | 2 | مع/بدون token |
| `logout` | 1 | يُصدر Unauthenticated |

### 5. `my_orders_cubit_test.dart` — قائمة الطلبات
| الـ Group | ما يختبره |
|---------|---------|
| `fetchMyOrders` | Loading → Success/Failure، قائمة فارغة |
| State types | التحقق من كل state class |
| UX logic | كل أنواع الطلبات تظهر، الترتيب محفوظ |

### 6. `chat_linkify_test.dart` — روابط المساعد الذكي
| الـ Group | ما يختبره |
|---------|---------|
| URL خام | `https://` و `http://` و `www.` → markdown |
| روابط Markdown | لا تُعدَّل إذا كانت موجودة مسبقاً |
| نص عادي | لا يتغير بدون URLs |
| حالات خاصة | Query params، قوائم، Bold مع روابط |

---

## مبادئ الكتابة
- **No emulator** — tests كود خالص (pure Dart unit tests)
- **No mocks frameworks** — Mock classes يدوية لوضوح أكبر
- **Isolated** — كل test مستقل ولا يعتمد على test آخر
- **Arabic-first** — أسماء الـ tests بالعربي للوضوح
- **UX-aware** — يختبر UX flows وليس فقط functions

## حالات تحتاج integration tests (مستقبلاً)
- [ ] انتقال SplashScreen → LoginScreen
- [ ] ضغط زر "استكمال" والانتقال للشاشة الصحيحة
- [ ] تغيير الثيم والتحقق من تحديث الـ UI
- [ ] فتح رابط خارجي من ChatBubble
