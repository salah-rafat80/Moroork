import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import '../document_upload/driving_license_upload_documents_screen.dart';
import 'widgets/agreement_checkbox.dart';
import 'widgets/terms_content_card.dart';

/// Terms & Conditions screen — displayed before the user proceeds to renew
/// or issue a driving licence.
///
/// State management is intentionally local ([StatefulWidget]) and limited to
/// [_isAgreed]. When this screen is wired to a Cubit, replace the local
/// state with the corresponding Cubit state and convert to [StatelessWidget].
class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  /// Tracks whether the user has accepted the terms.
  /// Drives the enabled / disabled state of the primary action button.
  bool _isAgreed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onAgreementChanged(bool value) {
    setState(() => _isAgreed = value);
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DrivingLicenseUploadDocumentsScreen(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: 'اصدار رخصة قيادة',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),

                  // ── Section header ─────────────────────────────────────
                  Text(
                    'الشروط والاحكام',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ── Sub-header ─────────────────────────────────────────
                  Text(
                    'يرجى قراءة الشروط بعناية قبل متابعة التجديد.',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Terms content ──────────────────────────────────────
                  const TermsContentCard(),

                  SizedBox(height: 16.h),

                  // ── Agreement checkbox ─────────────────────────────────
                  AgreementCheckbox(
                    isAgreed: _isAgreed,
                    onChanged: _onAgreementChanged,
                  ),

                  SizedBox(height: 16.h),

                  // ── Primary action button (reused from signup flow) ────
                  PrimaryButton(
                    onPressed: _isAgreed ? _onNextPressed : null,
                    label: 'التالي',
                    height: 48.h,
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
