import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable card that represents a single uploadable document.
///
/// **States driven by [isUploaded]:**
/// - `false` → grey dashed border + cloud-upload icon + "اضغط لرفع الملف"
/// - `true`  → green solid border + light-green background + checkmark +
///             "تم الرفع" + [onPreviewTapped] / [onDeleteTapped] side actions
///
/// The widget is intentionally "dumb" — all state is provided from outside,
/// making it trivial to wire to a Cubit later.
class UploadDocumentCard extends StatelessWidget {
  /// Document label shown at the top-right of the card.
  final String title;

  /// Whether [title] is marked as required (appends a red asterisk).
  final bool isRequired;

  /// Whether the document has already been uploaded.
  final bool isUploaded;

  /// Called when the user taps the upload zone (only when [isUploaded] is false).
  final VoidCallback? onUploadTapped;

  /// Called when the user taps "معاينة" (only when [isUploaded] is true).
  final VoidCallback? onPreviewTapped;

  /// Called when the user taps "حذف" (only when [isUploaded] is true).
  final VoidCallback? onDeleteTapped;

  /// The file-name to display beneath the green success bar.
  /// e.g. "id_front.jpg". Pass `null` to omit.
  final String? fileName;

  // ── Colours ───────────────────────────────────────────────────────────────
  static final Color _uploadedBorder = AppColors.successGreen;
  static final Color _uploadedBg = AppColors.lightGreenBorder;
  static final Color _pendingBorder = AppColors.greyIcon;
  static final Color _cardBg = AppColors.cardBg;
  static final Color _cardBorder = AppColors.greyBorder;
  static final Color _subtitleColor = AppColors.lightPurpleGrey;

  const UploadDocumentCard({
    super.key,
    required this.title,
    this.isRequired = false,
    required this.isUploaded,
    this.fileName,
    this.onUploadTapped,
    this.onPreviewTapped,
    this.onDeleteTapped,
  });

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: _cardBorder, width: 1.w),
      ),
      padding: EdgeInsets.all(12.r),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main content (takes remaining space) ──────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title row
                _TitleRow(title: title, isRequired: isRequired),
                SizedBox(height: 4.h),
                // Accepted formats hint
                Text(
                  'صيغ الملفات المقبولة: JPG, PNG, PDF',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: _subtitleColor,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                // Upload zone
                _UploadZone(
                  isUploaded: isUploaded,
                  onUploadTapped: onUploadTapped,
                ),
                if (isUploaded && fileName != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    fileName!,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.lightPurpleGrey,
                      fontSize: 11.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Side actions (only visible when uploaded) ─────────────────
          if (isUploaded) ...[
            SizedBox(width: 8.w),
            _SideActions(
              onPreviewTapped: onPreviewTapped,
              onDeleteTapped: onDeleteTapped,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final String title;
  final bool isRequired;

  const _TitleRow({required this.title, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    if (!isRequired) {
      return Text(
        title,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.sp,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.alertRed,
              fontSize: 15.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
    );
  }
}

class _UploadZone extends StatelessWidget {
  final bool isUploaded;
  final VoidCallback? onUploadTapped;

  const _UploadZone({required this.isUploaded, this.onUploadTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploaded ? null : onUploadTapped,
      child: Container(
        height: 40.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isUploaded
              ? UploadDocumentCard._uploadedBg
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          border: isUploaded
              ? Border.all(
                  color: UploadDocumentCard._uploadedBorder,
                  width: 1.w,
                )
              : Border.all(
                  color: UploadDocumentCard._pendingBorder,
                  width: 1.w,
                  // Dash effect via CustomPaint is complex — a solid thin grey
                  // border faithfully represents the design intent while keeping
                  // the widget zero-dependency. Swap with a dashed_border package
                  // if the designer requires it.
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            if (isUploaded) ...[
              Icon(
                Icons.check_circle,
                color: UploadDocumentCard._uploadedBorder,
                size: 20.r,
              ),
              SizedBox(width: 6.w),
              Text(
                'تم الرفع',
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.darkGrey,
                size: 20.r,
              ),
              SizedBox(width: 6.w),
              Text(
                'اضغط لرفع الملف',
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SideActions extends StatelessWidget {
  final VoidCallback? onPreviewTapped;
  final VoidCallback? onDeleteTapped;

  const _SideActions({this.onPreviewTapped, this.onDeleteTapped});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onDeleteTapped,
          child: Column(
            children: [
              Icon(
                Icons.delete_outline,
                size: 16.r,
                color: AppColors.lightPurpleGrey,
              ),
              Text(
                'حذف',
                style: TextStyle(
                  color: AppColors.lightPurpleGrey,
                  fontSize: 10.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onPreviewTapped,
          child: Column(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16.r,
                color: AppColors.lightPurpleGrey,
              ),
              Text(
                'معاينة',
                style: TextStyle(
                  color: AppColors.lightPurpleGrey,
                  fontSize: 10.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
