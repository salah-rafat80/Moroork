// path: lib/features/settings/presentation/screens/faq_screen.dart
import 'package:flutter/gestures.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/home/models/search_suggestion_model.dart';
import 'package:traffic/features/home/presentation/widgets/search_navigation_helper.dart';

class FaqModel {
  final String question;
  final String preText;
  final String underlinedText;
  final String postText;
  final SearchServiceType serviceType;

  const FaqModel({
    required this.question,
    required this.preText,
    required this.underlinedText,
    required this.postText,
    required this.serviceType,
  });
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<FaqModel> faqs = const [
    FaqModel(
      question: 'كيف يمكنني الاستعلام عن مخالفات القيادة وسدادها؟',
      preText:
          'لتسهيل متابعة غرامات السير الخاصة بك، يمكنك إجراء فحص فوري وسريع لجميع المخالفات المسجلة إلكترونياً على رخصتك. تفضل بزيارة خدمة ',
      underlinedText: 'الاستعلام عن مخالفات رخصة القيادة',
      postText:
          ' لإدخل رقم رخصتك، عرض بيان التفاصيل، ومن ثم السداد الآمن والمباشر لرسوم التصالح.',
      serviceType: SearchServiceType.drivingLicenseViolations,
    ),
    FaqModel(
      question: 'ما هي خطوات تجديد رخصة قيادتي منتهية الصلاحية؟',
      preText:
          'بإمكانك تجديد رخصة القيادة الخاصة بك بشكل رقمي كامل عبر منصتنا دون الحاجة للانتظار. فقط قم بالدخول إلى خدمة ',
      underlinedText: 'تجديد رخصة القيادة',
      postText:
          ' للبدء في حجز الكشف الطبي المناسب، إرفاق المستندات المطلوبة، وسداد رسوم التجديد المقررة للحصول على الرخصة الجديدة.',
      serviceType: SearchServiceType.renewDrivingLicense,
    ),
    FaqModel(
      question: 'لقد فُقدت رخصة سيارتي، كيف أستخرج رخصة بديلة؟',
      preText:
          'إذا تعرضت رخصة مركبتك للتلف أو الفقدان، يمكنك طلب إصدار نسخة بديلة ومطابقة للرخصة الرسمية مباشرة. انتقل إلى خدمة ',
      underlinedText: 'بدل فاقد/تالف رخصة المركبة',
      postText:
          ' وتأكيد ملكية المركبة ومراجعة بياناتك لتقديم الطلب وإتمام الدفع بأمان وسهولة.',
      serviceType: SearchServiceType.lostDamagedVehicleLicense,
    ),
    FaqModel(
      question: 'كيف أتحقق من المخالفات المسجلة على مركبتي؟',
      preText:
          'لمعرفة كافة الغرامات والمخالفات المسجلة على لوحة سيارتك والاطلاع على تفاصيلها وقيمتها المالية، يمكنك استخدام خدمة ',
      underlinedText: 'الاستعلام عن مخالفات رخص المركبات',
      postText:
          ' للتحقق الآني والسهل وسدادها لضمان صلاحية أوراق مركبتك دون غرامات إضافية.',
      serviceType: SearchServiceType.vehicleLicenseViolations,
    ),
    FaqModel(
      question: 'أريد تجديد رخصة سيارتي، ما هي الإجراءات اللازمة؟',
      preText:
          'تتيح لك المنصة إنهاء كافة إجراءات تجديد رخص المركبات المنتهية بكل يسر وسهولة. ابدأ فوراً بزيارة خدمة ',
      underlinedText: 'تجديد رخصة المركبة',
      postText:
          ' لتعبئة استمارة التجديد، إثبات الفحص الفني، دفع التأمين والرسوم المطلوبة، وتتبع توصيل الرخصة لعنوانك.',
      serviceType: SearchServiceType.renewVehicleLicense,
    ),
    FaqModel(
      question: 'كيف أستخرج رخصة قيادة لأول مرة عبر المنصة؟',
      preText:
          'للمواطنين الراغبين في إصدار رخصة قيادة جديدة لأول مرة، توفر المنصة الدليل التفاعلي لحجز مدرسة القيادة. ابدأ الآن بالاطلاع عبر خدمة ',
      underlinedText: 'إصدار رخصة قيادة لأول مرة',
      postText:
          ' للموافقة على الشروط والأحكام ورفع ملف الكشف الطبي وبدء التدريب العملي.',
      serviceType: SearchServiceType.issueDrivingLicenseFirstTime,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        textDirection: TextDirection.rtl,
        children: [
          ServiceScreenAppBar(
            title: "الاسئلة الشائعة",
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _FaqItemCard(faq: faq),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItemCard extends StatefulWidget {
  final FaqModel faq;

  const _FaqItemCard({required this.faq});

  @override
  State<_FaqItemCard> createState() => _FaqItemCardState();
}

class _FaqItemCardState extends State<_FaqItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.greyBorder, width: 1.w),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ExpansionTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
              size: 22.r,
            ),
            title: Text(
              widget.faq.question,
              style: TextStyle(
                color: _isExpanded
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 14.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            trailing: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _isExpanded
                  ? AppColors.primary
                  : const Color(0xFF888888),
              size: 24.r,
            ),
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                child: FaqAnswerText(
                  preText: widget.faq.preText,
                  underlinedText: widget.faq.underlinedText,
                  postText: widget.faq.postText,
                  serviceType: widget.faq.serviceType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqAnswerText extends StatefulWidget {
  final String preText;
  final String underlinedText;
  final String postText;
  final SearchServiceType serviceType;

  const FaqAnswerText({
    super.key,
    required this.preText,
    required this.underlinedText,
    required this.postText,
    required this.serviceType,
  });

  @override
  State<FaqAnswerText> createState() => _FaqAnswerTextState();
}

class _FaqAnswerTextState extends State<FaqAnswerText> {
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        SearchNavigationHelper.navigateToService(context, widget.serviceType);
      };
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: widget.preText,
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
          TextSpan(
            text: widget.underlinedText,
            recognizer: _tapGestureRecognizer,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              height: 1.6,
            ),
          ),
          TextSpan(
            text: widget.postText,
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}
