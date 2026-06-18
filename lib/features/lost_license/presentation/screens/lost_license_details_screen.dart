import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/driving_license/presentation/screens/license_details/widgets/license_info_card.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import 'replacement_type_selection_screen.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
///
/// The user reviews the details of the licence they have selected for
/// replacement. The card is displayed in a confirmed (green-bordered, selected)
/// state. This screen is part of the "Lost/Damaged Driving License Replacement"
/// flow.
class LostLicenseDetailsScreen extends StatefulWidget {
  /// The licence chosen by the user on the previous screen.
  final DrivingLicenseModel license;

  const LostLicenseDetailsScreen({super.key, required this.license});

  @override
  State<LostLicenseDetailsScreen> createState() =>
      _LostLicenseDetailsScreenState();
}

class _LostLicenseDetailsScreenState extends State<LostLicenseDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Handlers ────────────────────────────────────────────────────────────────

  void _onNextPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReplacementTypeSelectionScreen(license: widget.license),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightGreyBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── App bar ──────────────────────────────────────────────────────
          ServiceScreenAppBar(
            title: 'استخراج بدل فاقد / تالف',
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  // Green-bordered container replicates the "selected" visual
                  // state to confirm the user's choice.
                  _ConfirmedLicenseCard(data: widget.license),
                ],
              ),
            ),
          ),

          // ── Primary action button at the very bottom ──────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: PrimaryButton(
              label: 'التالي',
              onPressed: () => _onNextPressed(context),
              height: 48.h,
            ),
          ),
        ],
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
