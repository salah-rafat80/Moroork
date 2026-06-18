import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A read-only card that renders the full Terms & Conditions text.
///
/// This widget is intentionally "dumb" — it holds no state and accepts
/// no callbacks. It is ready to be driven by a Cubit in the future.
class TermsContentCard extends StatelessWidget {
  const TermsContentCard({super.key});

  // ── Private helpers ──────────────────────────────────────────────────────

  TextSpan _heading(String text) => TextSpan(
    text: text,
    style: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 13.sp,
      fontFamily: 'Tajawal',
      fontWeight: FontWeight.w700,
      height: 1.8,
    ),
  );

  TextSpan _body(String text) => TextSpan(
    text: text,
    style: TextStyle(
      color: AppColors.darkGrey,
      fontSize: 13.sp,
      fontFamily: 'Tajawal',
      fontWeight: FontWeight.w500,
      height: 1.6,
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: AppColors.greyBorder),
          borderRadius: BorderRadius.circular(5.r),
        ),
      ),
      padding: EdgeInsets.all(12.r),
      child: Text.rich(
        TextSpan(
          children: [
            _heading('1. صحة البيانات\n'),
            _body(
              'يقرّ المستخدم بأن جميع البيانات الشخصية وبيانات المركبة التي يتم إدخالها صحيحة ودقيقة، وأن أي خطأ أو تزوير يُعرّضه للمساءلة القانونية.\n\n',
            ),
            _heading('2. صحة المستندات\n'),
            _body(
              'يتعهد المستخدم بتقديم مستندات رسمية سارية، ويوافق على أن المرور يحق له رفض الطلب في حالة وجود مستندات غير واضحة أو غير مطابقة للحقيقة.\n\n',
            ),
            _heading('3. الفحص الفني الإلزامي\n'),
            _body(
              'يلتزم المستخدم بإحضار المركبة للفحص الفني في الموعد المحدد، ويُعتبر هذا الفحص شرطًا أساسيًا لإصدار الرخصة.\n\n',
            ),
            _heading('4. الكشف الطبي للسائق\n'),
            _body(
              'يوافق المستخدم على إجراء الكشف الطبي المطلوب للتحقق من اللياقة الصحية اللازمة لقيادة المركبة، وفي حال عدم اجتيازه يتم وقف الطلب.\n\n',
            ),
            _heading('5. الرسوم المقررة\n'),
            _body(
              'يقرّ المستخدم بأن عليه سداد جميع الرسوم الحكومية، بما في ذلك رسوم الترخيص والفحص الفني والتأمين الإجباري، ولا يتم إصدار الرخصة إلا بعد الدفع الكامل.\n\n',
            ),
            _heading('6. التأمين الإجباري على المركبة\n'),
            _body(
              'يلتزم المستخدم بإصدار وثيقة التأمين الإجباري للمركبة، ويوافق على مشاركة بياناته مع شركة التأمين المعتمدة.\n\n',
            ),
            _heading('7. مراجعة البيانات قبل الدفع\n'),
            _body(
              'يقوم المستخدم بمراجعة جميع بيانات المركبة والسائق قبل الدفع، ويُعتبر تأكيده موافقة نهائية لا يمكن الرجوع عنها بعد سداد الرسوم.\n\n',
            ),
            _heading('8. مشاركة البيانات مع الجهات المختصة\n'),
            _body(
              'يوافق المستخدم على السماح للمنظومة بمشاركة بياناته مع الإدارة العامة للمرور، وشركات الفحص الفني، وشركات التأمين عند الحاجة.\n\n',
            ),
            _heading('9. إلغاء الطلب أو رفضه\n'),
            _body(
              'يحق للمرور إلغاء أو رفض أي طلب إذا تبيّن وجود بيانات غير صحيحة، أو إذا لم يستوفِ المستخدم المتطلبات خلال المهلة المحددة.\n\n',
            ),
            _heading('10. الالتزام بالقوانين المرورية\n'),
            _body(
              'يقرّ المستخدم بأنه على دراية بقانون المرور ولائحته التنفيذية، ويلتزم بجميع الإجراءات والتعليمات أثناء تقديم الطلب.\n\n',
            ),
            _heading('11. استخدام الخدمة الإلكترونية\n'),
            _body(
              'يوافق المستخدم على أن الخدمة الإلكترونية لا تُغني عن زيارة وحدة المرور عند الحاجة، مثل استلام اللوحات أو الفحص الحضوري.\n\n',
            ),
            _heading('12. الإخطارات والتنبيهات\n'),
            _body(
              'يوافق المستخدم على استقبال إشعارات بخصوص الطلب، والمواعيد، وأي مستندات ناقصة عبر التطبيق أو الرسائل النصية.',
            ),
          ],
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
