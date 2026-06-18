import 'package:file_picker/file_picker.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'upload_document_card.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class DocumentItemModel {
  final String title;
  final bool isRequired;
  final List<String> allowedExtensions;
  String? filePath;
  String? fileName;

  DocumentItemModel({
    required this.title,
    required this.isRequired,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
  });

  bool get isUploaded => filePath != null;
}

class DropdownConfig {
  final String title;
  final String hint;
  final List<String> options;

  const DropdownConfig({
    required this.title,
    required this.hint,
    required this.options,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class GenericDocumentUploadScreen extends StatefulWidget {
  final String appBarTitle;
  final String subtitle;
  final List<DropdownConfig>? dropdowns;
  final List<DocumentItemModel> documents;
  final void Function(Map<String, String> selectedDropdowns) onNextPressed;

  const GenericDocumentUploadScreen({
    super.key,
    required this.appBarTitle,
    required this.subtitle,
    this.dropdowns,
    required this.documents,
    required this.onNextPressed,
  });

  @override
  State<GenericDocumentUploadScreen> createState() =>
      _GenericDocumentUploadScreenState();
}

class _GenericDocumentUploadScreenState
    extends State<GenericDocumentUploadScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Stores selected string for each dropdown title
  final Map<String, String?> _selectedDropdowns = {};

  bool get _canProceed {
    if (widget.dropdowns != null) {
      for (final dp in widget.dropdowns!) {
        if (_selectedDropdowns[dp.title] == null) return false;
      }
    }
    return widget.documents
        .where((d) => d.isRequired)
        .every((d) => d.isUploaded);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _openGenericSheet(DropdownConfig config) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      backgroundColor: AppColors.background,
      builder: (_) => GenericOptionsBottomSheet(
        title: config.hint,
        options: config.options,
      ),
    );
    if (result != null) {
      setState(() => _selectedDropdowns[config.title] = result);
    }
  }

  Future<void> _onUploadTapped(int index) async {
    try {
      final doc = widget.documents[index];
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: doc.allowedExtensions,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.path == null) return;

      setState(() {
        doc.filePath = file.path;
        doc.fileName = file.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء اختيار الملف. يرجى المحاولة مجدداً.',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onDeleteTapped(int index) {
    setState(() {
      widget.documents[index].filePath = null;
      widget.documents[index].fileName = null;
    });
  }

  Future<void> _onPreviewTapped(int index) async {
    final path = widget.documents[index].filePath;
    if (path == null) return;
    await OpenFilex.open(path);
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
          ServiceScreenAppBar(
            title: widget.appBarTitle,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'رفع المستندات المطلوبة',
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
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (widget.dropdowns != null)
                    ...widget.dropdowns!.expand(
                      (dropdown) => [
                        Text(
                          dropdown.title,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _CategoryPickerField(
                          selectedValue: _selectedDropdowns[dropdown.title],
                          hint: dropdown.hint,
                          onTap: () => _openGenericSheet(dropdown),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),

                  ...List.generate(widget.documents.length, (i) {
                    final doc = widget.documents[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: UploadDocumentCard(
                        title: doc.title,
                        isRequired: doc.isRequired,
                        isUploaded: doc.isUploaded,
                        fileName: doc.fileName,
                        onUploadTapped: () => _onUploadTapped(i),
                        onPreviewTapped: () => _onPreviewTapped(i),
                        onDeleteTapped: () => _onDeleteTapped(i),
                      ),
                    );
                  }),

                  SizedBox(height: 8.h),
                  PrimaryButton(
                    onPressed: _canProceed
                        ? () => widget.onNextPressed(
                            _selectedDropdowns.cast<String, String>(),
                          )
                        : null,
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

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPickerField extends StatelessWidget {
  final String? selectedValue;
  final String hint;
  final VoidCallback onTap;

  const _CategoryPickerField({
    required this.selectedValue,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedValue != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.primary, width: 1.w),
          color: AppColors.inputFieldBg,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                selectedValue ?? hint,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasSelection
                      ? AppColors.textPrimary
                      : AppColors.greyIcon,
                  fontSize: 15.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.r,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class GenericOptionsBottomSheet extends StatelessWidget {
  final String title;
  final List<String> options;

  const GenericOptionsBottomSheet({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 12.h,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.greyBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                title,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Material(
                    color: AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: AppColors.greyBorder,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < options.length; i++) ...[
                            InkWell(
                              onTap: () => Navigator.pop(context, options[i]),
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 14.h,
                                  ),
                                  child: Text(
                                    options[i],
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15.sp,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (i < options.length - 1)
                              Divider(
                                height: 1.h,
                                thickness: 1.h,
                                color: AppColors.greyBorder,
                                indent: 0,
                                endIndent: 0,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
