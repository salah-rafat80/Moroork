import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/checkout/edit_applicant_details_screen.dart';
import 'package:traffic/core/features/checkout/models/applicant_details.dart';
import 'package:traffic/core/features/checkout/models/fees_details.dart';
import 'package:traffic/core/features/checkout/models/order_summary.dart';
import 'package:traffic/core/features/checkout/widgets/applicant_details_card.dart';
import 'package:traffic/core/features/checkout/widgets/fees_details_card.dart';
import 'package:traffic/core/features/checkout/widgets/order_summary_card.dart';
import 'package:traffic/core/features/payment/models/payment_intent.dart';
import 'package:traffic/core/features/payment/screens/payment_method_screen.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/app_drawer.dart';

/// A fully generic "Order Review / Checkout Summary" screen.
///
/// Designed to be reused across flows:
///   • Renewal (تجديد رخصة)
///   • Lost / Damaged (فقدان أو تلف)
///   • First-time Issuance (إصدار لأول مرة)
///
/// All content is injected via the constructor — no business logic lives here.
class GenericOrderReviewScreen extends StatefulWidget {
  // ── AppBar ────────────────────────────────────────────────────────────────
  /// Title displayed in the top app-bar, e.g. 'تجديد رخصة مركبة'.
  final String appBarTitle;

  // ── Section subtitle ──────────────────────────────────────────────────────
  /// Section title rendered below the app-bar (defaults to 'مراجعة الطلب').
  final String sectionTitle;

  // ── Content models ────────────────────────────────────────────────────────
  final ApplicantDetails applicantDetails;
  final OrderSummary orderSummary;
  final FeesDetails feesDetails;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  /// Whether to show the "تعديل" edit button on the applicant card.
  final bool showEditApplicant;

  /// Called after the success toast is shown.
  /// Defaults to [Navigator.popUntil] back to the first route when null.
  final VoidCallback? onSubmitSuccess;

  /// Service request number to be passed to the payment flow.
  final String? serviceRequestNumber;

  /// Explicit amount used for payment when available from API response.
  final double? paymentAmountOverride;

  const GenericOrderReviewScreen({
    super.key,
    required this.appBarTitle,
    this.sectionTitle = 'مراجعة الطلب',
    required this.applicantDetails,
    required this.orderSummary,
    required this.feesDetails,
    this.showEditApplicant = true,
    this.onSubmitSuccess,
    this.serviceRequestNumber,
    this.paymentAmountOverride,
  });

  @override
  State<GenericOrderReviewScreen> createState() =>
      _GenericOrderReviewScreenState();
}

class _GenericOrderReviewScreenState extends State<GenericOrderReviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Mutable copy so the edit screen can update applicant details.
  late ApplicantDetails _applicantDetails;

  @override
  void initState() {
    super.initState();
    _applicantDetails = widget.applicantDetails;
  }

  // ── Edit applicant ────────────────────────────────────────────────────────

  Future<void> _onEditApplicant() async {
    final updated = await Navigator.push<ApplicantDetails>(
      context,
      MaterialPageRoute(
        builder: (_) => EditApplicantDetailsScreen(
          appBarTitle: widget.appBarTitle,
          currentDetails: _applicantDetails,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _applicantDetails = updated);
    }
  }

  // ── Submission logic ──────────────────────────────────────────────────────

  void _handleSubmit() {
    final double amount;
    if (widget.paymentAmountOverride != null) {
      amount = widget.paymentAmountOverride!;
    } else {
      // Fallback for existing callers that only provide formatted fee text.
      final String amountStr = widget.feesDetails.total.replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      amount = double.tryParse(amountStr) ?? 0.0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          paymentIntent: PaymentIntent(
            orderType: widget.orderSummary.orderType,
            amount: amount,
            currency: 'جنية مصري',
            serviceRequestNumber: widget.serviceRequestNumber,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ─────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: widget.appBarTitle,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable body ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Section title
                  Text(
                    widget.sectionTitle,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Applicant card
                  ApplicantDetailsCard(
                    details: _applicantDetails,
                    onEditPressed: widget.showEditApplicant
                        ? _onEditApplicant
                        : null,
                  ),
                  SizedBox(height: 16.h),

                  // Order summary card
                  OrderSummaryCard(summary: widget.orderSummary),
                  SizedBox(height: 16.h),

                  // Fees details card
                  FeesDetailsCard(fees: widget.feesDetails),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed Bottom Button (Fitts's Law: Sticky zone) ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: PrimaryButton(
              label: 'التالي',
              onPressed: _handleSubmit,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }
}

