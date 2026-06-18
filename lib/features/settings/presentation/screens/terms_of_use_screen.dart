import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/settings/presentation/widgets/term_info_card.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> _terms = [
    {
      'title': '1. القبول والموافقة',
      'content':
          'باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بشروط الاستخدام هذه. إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.',
    },
    {
      'title': '2. استخدام الخدمة',
      'content':
          'يجب استخدام التطبيق للأغراض القانونية فقط. يحظر استخدام التطبيق بأي طريقة قد تضر بالخدمة أو تعطلها أو تؤثر على استخدام الآخرين لها.',
    },
    {
      'title': '3. حساب المستخدم',
      'content':
          'أنت مسؤول عن الحفاظ على سرية معلومات حسابك وكلمة المرور الخاصة بك. تتحمل المسؤولية الكاملة عن جميع الأنشطة التي تتم من خلال حسابك.',
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
            title: 'شروط الاستخدام',
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
                      'يرجى قراءة شروط الاستخدام بعناية قبل استخدام التطبيق. استخدامك للتطبيق يعني موافقتك على هذه الشروط.',
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
                    ..._terms.map((term) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TermInfoCard(
                            title: term['title']!,
                            content: term['content']!,
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
