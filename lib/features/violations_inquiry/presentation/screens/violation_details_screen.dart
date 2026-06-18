import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/payment/models/payment_intent.dart';
import 'package:traffic/core/features/payment/screens/payment_method_screen.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/violations_inquiry/data/models/violation_model.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_details_card.dart';
import 'package:traffic/features/violations_inquiry/presentation/widgets/violation_pay_button.dart';

/// Displays the full details of a single [ViolationModel].
///
/// Shows the violation card (title, status tag, illustration, detail rows)
/// and a pay button at the bottom for unpaid violations.
class ViolationDetailsScreen extends StatefulWidget {
  final ViolationModel violation;

  const ViolationDetailsScreen({super.key, required this.violation});

  @override
  State<ViolationDetailsScreen> createState() => _ViolationDetailsScreenState();
}

class _ViolationDetailsScreenState extends State<ViolationDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final v = widget.violation;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App Bar ──
          ServiceScreenAppBar(
            title: 'سداد مخالفات رخصة المركبة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 16.h),

                  // ── Section title (right-aligned) ──
                  Text(
                    'تفاصيل المخالفة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Main details card ──
                  ViolationDetailsCard(violation: v),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // ── Bottom pay button (unpaid violations only) ──
          if (!v.isPaid)
            ViolationPayButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentMethodScreen(
                    paymentIntent: PaymentIntent(
                      orderType: 'سداد مخالفات رخصة المركبة',
                      amount: v.amount,
                      currency: 'جنية مصري',
                      violationIds: [v.violationId],
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
}
