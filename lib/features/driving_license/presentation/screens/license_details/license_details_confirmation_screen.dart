import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/auth/presentation/screens/signup_screen/widgets/signup_step1_form/widgets/next_button_widget.dart';
import 'package:traffic/features/driving_license/presentation/screens/theory_test/theory_test_booking_screen.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'widgets/license_info_card.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// **Selected Licence Confirmation Screen** — the user reviews the details of
/// the licence they have selected to renew before proceeding.
///
/// This screen is part of the "License Renewal Flow". It receives the already-
/// selected [DrivingLicenseModel] and renders it in a read-only, confirmed
/// state (green border, selected radio dot). The "التالي" button navigates to
/// [TheoryTestBookingScreen].
class LicenseDetailsConfirmationScreen extends StatefulWidget {
  /// The licence chosen by the user on the previous screen.
  final DrivingLicenseModel license;

  const LicenseDetailsConfirmationScreen({
    super.key,
    required this.license,
  });

  @override
  State<LicenseDetailsConfirmationScreen> createState() => _LicenseDetailsConfirmationScreenState();
}

class _LicenseDetailsConfirmationScreenState extends State<LicenseDetailsConfirmationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Handlers ────────────────────────────────────────────────────────────────

  void _onNextPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TheoryTestBookingScreen(
          appBarTitle: 'تجديد رخصة القيادة',
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.lightGreyBg,
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            ServiceScreenAppBar(
              title: 'تجديد رخصة القيادة',
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Section header ────────────────────────────────────────
                    Text(
                      'تفاصيل رخصة القيادة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Confirmed licence card ────────────────────────────────
                    // Wrapped in a green-bordered container to match the
                    // "selected" state shown in the design.
                    _ConfirmedLicenseCard(data: widget.license),
                  ],
                ),
              ),
            ),

            // ── Primary action button at the very bottom ──────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: NextButtonWidget(
                onPressed: () => _onNextPressed(context),
                isValid: true,
                height: 48.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widget ────────────────────────────────────────────────────────

/// Renders [LicenseInfoCard] in a selected state (green border) mimicking the
/// visual state of a confirmed / selected licence.
class _ConfirmedLicenseCard extends StatelessWidget {
  final DrivingLicenseModel data;

  const _ConfirmedLicenseCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return LicenseInfoCard(
      data: data,
      isSelected: true,
      showRadioDot: false,
    );
  }
}

