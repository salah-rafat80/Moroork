import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/features/payment/models/payment_intent.dart';
import 'package:traffic/core/features/payment/widgets/payment_summary_card.dart';
import 'package:traffic/core/widgets/primary_button.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/features/driving_license/presentation/screens/terms_and_conditions/widgets/agreement_checkbox.dart';
import 'package:traffic/features/lost_license/presentation/widgets/custom_text_form_field.dart';

class CreditCardEntryScreen extends StatefulWidget {
  final PaymentIntent paymentIntent;

  const CreditCardEntryScreen({super.key, required this.paymentIntent});

  @override
  State<CreditCardEntryScreen> createState() => _CreditCardEntryScreenState();
}

class _CreditCardEntryScreenState extends State<CreditCardEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isAgreedToTerms = false;
  bool _isLoading = false;
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _onConfirmPayment() async {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (!_isAgreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'برجاء الموافقة على الشروط والأحكام',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.alertRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Fake payment delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تأكيد الدفع بنجاح!', // Placeholder success
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Optionally pop back to root or a success screen
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyBg,
        body: Column(
          children: [
            // App bar
            ServiceScreenAppBar(title: widget.paymentIntent.orderType),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Text(
                      'اتمام الدفع',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Summary card
                    PaymentSummaryCard(paymentIntent: widget.paymentIntent),
                    SizedBox(height: 16.h),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Number
                          CustomTextFormField(
                            labelText: 'رقم البطاقة',
                            hintText: '12345679092345678',
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'برجاء إدخال رقم البطاقة';
                              }
                              // A basic 16-digit check (can be improved depending on exact validation needed)
                              if (value.replaceAll(' ', '').length < 16) {
                                return 'رقم البطاقة غير صحيح, برجاء ادخال 16 رقم';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Card Holder Name
                          CustomTextFormField(
                            labelText: 'اسم حامل البطاقة',
                            hintText: 'اميرة عصام',
                            controller: _cardHolderController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'اسم صاحب البطاقة غير صحيح.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Expiry Date and CVV Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  labelText: 'تاريخ الانتهاء',
                                  hintText:
                                      'MM/YY', // A slightly friendlier hint than '_'
                                  controller: _expiryDateController,
                                  keyboardType: TextInputType.datetime,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'تاريخ الانتهاء غير صالح.';
                                    }
                                    if (!RegExp(
                                      r'^\d{2}/\d{2}$',
                                    ).hasMatch(value)) {
                                      return 'التنسيق الصحيح MM/YY';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: CustomTextFormField(
                                  labelText: 'CVV',
                                  hintText: '123',
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'الرقم غير صحيح';
                                    }
                                    if (value.length < 3 || value.length > 4) {
                                      return 'الرقم غير صحيح';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // Secure connection note
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .gpp_good_outlined, // Closer to the shield/secure icon
                                color: AppColors.primary,
                                size: 16.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'عملية الدفع مؤمنة عبر بطاقة الدفع الحكومية.',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.deepGrey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Terms agreement
                          AgreementCheckbox(
                            isAgreed: _isAgreedToTerms,
                            onChanged: (val) =>
                                setState(() => _isAgreedToTerms = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: _isLoading
                  ? Center(
                      child: CustomLoadingIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : PrimaryButton(
                      label: 'تأكيد الدفع',
                      onPressed: _onConfirmPayment,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
