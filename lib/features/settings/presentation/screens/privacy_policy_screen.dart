import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/settings/presentation/widgets/term_info_card.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> _privacyPoints = [
    {
      'title': '1. جمع المعلومات',
      'content':
          'نقوم بجمع المعلومات التي تقدمها عند التسجيل في التطبيق أو استخدام خدماتنا، بما في ذلك الاسم، رقم الهوية، رقم الجوال، البريد الإلكتروني، وغيرها من المعلومات الضرورية لتقديم الخدمات.',
    },
    {
      'title': '2. استخدام المعلومات',
      'content':
          'نستخدم معلوماتك الشخصية لتقديم وتحسين خدماتنا، معالجة طلباتك، التواصل معك، وضمان أمان حسابك. كما نستخدمها للامتثال للمتطلبات القانونية والتنظيمية.',
    },
    {
      'title': '3. حماية البيانات',
      'content':
          'نطبق إجراءات أمنية صارمة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الاستخدام أو الإفصاح. نستخدم تقنيات التشفير والبروتوكولات الآمنة لحماية بياناتك.',
    },
    {
      'title': '4. الخصوصية والبيانات',
      'content':
          'نلتزم بحماية خصوصيتك وبياناتك الشخصية وفقاً لسياسة الخصوصية المعتمدة. يرجى مراجعة سياسة الخصوصية لمعرفة كيفية جمع واستخدام معلوماتك.',
    },
    {
      'title': '5. الملكية الفكرية',
      'content':
          'جميع المحتويات والمواد في التطبيق، بما في ذلك النصوص والصور والشعارات، هي ملكية حصرية للإدارة العامة للمرور ومحمية بموجب قوانين حقوق الملكية الفكرية.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ServiceScreenAppBar(
            title: 'سياسة الخصوصية',
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نحن ملتزمون بحماية خصوصيتك وأمان معلوماتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية بياناتك.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13.sp,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ..._privacyPoints.map((point) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TermInfoCard(
                            title: point['title']!,
                            content: point['content']!,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
