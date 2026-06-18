import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/driving_license/data/models/driving_license_model.dart';
import '../widgets/selection_option_card.dart';
import 'delivery_method_screen.dart';

import 'package:traffic/core/widgets/app_drawer.dart';

// ── Enum ──────────────────────────────────────────────────────────────────────

/// Represents the two possible replacement types for a driving licence.
enum ReplacementType {
  /// The licence was lost (بدل فاقد).
  lost,

  /// The licence is damaged (بدل تالف).
  damaged,
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// **Replacement Type Selection Screen** — Step 3 of the
/// "Lost / Damaged Driving Licence" flow (استخراج بدل فاقد / تالف رخصة قيادة).
///
/// The user selects whether their licence was *lost* (بدل فاقد) or
/// *damaged* (بدل تالف). The "التالي" button is disabled until a selection
/// is made.
class ReplacementTypeSelectionScreen extends StatefulWidget {
  /// The driving licence chosen by the user in the previous step.
  final DrivingLicenseModel license;

  const ReplacementTypeSelectionScreen({super.key, required this.license});

  @override
  State<ReplacementTypeSelectionScreen> createState() =>
      _ReplacementTypeSelectionScreenState();
}

class _ReplacementTypeSelectionScreenState
    extends State<ReplacementTypeSelectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Currently selected replacement type; `null` means nothing is selected yet.
  ReplacementType? selectedType;

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onOptionTap(ReplacementType type) {
    setState(() => selectedType = type);
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryMethodScreen(
          license: widget.license,
          replacementType: selectedType!,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
            title: 'اصدار بدل فاقد / تالف رخصة قيادة',
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
                    'نوع طلب الاستبدال',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Option: بدل فاقد (Lost) ──────────────────────────────
                  SelectionOptionCard(
                    title: 'بدل فاقد',
                    subtitle: 'استبدال الرخصة المفقودة',
                    isSelected: selectedType == ReplacementType.lost,
                    onTap: () => _onOptionTap(ReplacementType.lost),
                    icon: SvgPicture.asset(
                      'assets/file.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Option: بدل تالف (Damaged) ───────────────────────────
                  SelectionOptionCard(
                    title: 'بدل تالف',
                    subtitle: 'استبدال الرخصة التالفة',
                    isSelected: selectedType == ReplacementType.damaged,
                    onTap: () => _onOptionTap(ReplacementType.damaged),
                    icon: SvgPicture.asset(
                      'assets/file.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky bottom button ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: PrimaryButton(
              label: 'التالي',
              // Pass null when nothing is selected so PrimaryButton renders
              // in its disabled (grey) state automatically.
              onPressed: selectedType != null ? _onNextPressed : null,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }
}
