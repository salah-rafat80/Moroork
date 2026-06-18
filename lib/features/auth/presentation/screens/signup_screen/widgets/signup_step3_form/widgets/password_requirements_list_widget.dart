import 'package:flutter/material.dart';
import 'package:traffic/core/widgets/password_requirement_item.dart';

class PasswordRequirementsListWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool notSameAsUsername;

  const PasswordRequirementsListWidget({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.notSameAsUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordRequirementItem(text: '8 أحرف على الأقل', isMet: hasMinLength),
        PasswordRequirementItem(
          text: 'تحتوي على حرف كبير واحد على الأقل (A-Z)',
          isMet: hasUppercase,
        ),
        PasswordRequirementItem(
          text: 'تحتوي على حرف صغير واحد على الأقل (a-z)',
          isMet: hasLowercase,
        ),
        PasswordRequirementItem(
          text: 'تحتوي على رقم واحد على الأقل (0-9)',
          isMet: hasNumber,
        ),
        PasswordRequirementItem(
          text:
              'تحتوي على رمز خاص واحد على الأقل\n! @ # \$ % ^ & * ( ) _ + - = [ ] { } ; : \' " \\\\ | , . < > / ?',
          isMet: hasSpecialChar,
        ),
        PasswordRequirementItem(
          text: 'يجب ألا تكون كلمة المرور مطابقة لاسم المستخدم',
          isMet: notSameAsUsername,
        ),
      ],
    );
  }
}
