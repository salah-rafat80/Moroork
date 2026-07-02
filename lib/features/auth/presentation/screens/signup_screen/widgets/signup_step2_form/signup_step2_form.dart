import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/app_sizes.dart';
import 'package:traffic/core/widgets/custom_text_field.dart';
import 'widgets/form_title_widget.dart';
import 'widgets/field_label_widget.dart';
import 'widgets/error_message_widget.dart';
import 'widgets/terms_checkbox_widget.dart';
import 'widgets/navigation_buttons_widget.dart';

class SignupStep2Form extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController familyNameController;
  final TextEditingController nationalIdController;
  final String? nationalIdError;
  final bool acceptedTerms;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final bool isValid;

  const SignupStep2Form({
    super.key,
    required this.firstNameController,
    required this.familyNameController,
    required this.nationalIdController,
    this.nationalIdError,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.onFieldChanged,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.buttonHeightS;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const FormTitleWidget(title: 'البيانات الشخصية'),
            SizedBox(height: 20.h),
            // First name field
            const FieldLabelWidget(label: 'الاسم الأول'),
            SizedBox(height: 5.h),
            CustomTextField(
              controller: firstNameController,
              hintText: 'أدخل الاسم الأول',
              textAlign: TextAlign.right,
              onChanged: onFieldChanged,
            ),
            SizedBox(height: 10.h),
            // Family name field
            const FieldLabelWidget(label: 'اسم العائلة'),
            SizedBox(height: 5.h),
            CustomTextField(
              controller: familyNameController,
              hintText: 'أدخل اسم العائلة',
              textAlign: TextAlign.right,
              onChanged: onFieldChanged,
            ),
            SizedBox(height: 10.h),
            // National ID field
            const FieldLabelWidget(label: 'الرقم القومي'),
            SizedBox(height: 5.h),
            CustomTextField(
              controller: nationalIdController,
              hintText: 'أدخل الرقم القومي',
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              hasError: nationalIdError != null,
              maxLength: 14,
              onChanged: onFieldChanged,
            ),
            ErrorMessageWidget(errorMessage: nationalIdError),
            SizedBox(height: 20.h),
            // Terms checkbox
            TermsCheckboxWidget(
              acceptedTerms: acceptedTerms,
              onChanged: onTermsChanged,
            ),
            SizedBox(height: 0.1.sh),
            // Buttons
            NavigationButtonsWidget(
              onNextPressed: onNextPressed,
              onPreviousPressed: onPreviousPressed,
              isValid: isValid,
              buttonHeight: buttonHeight,
            ),
          ],
        ),
      ),
    );
  }
}
