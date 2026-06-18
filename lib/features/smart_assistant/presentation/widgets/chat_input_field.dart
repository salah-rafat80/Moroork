import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Redesigned premium bottom input field with a floating capsule look,
/// scale/glow animations, and responsive colors.
class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSend;

  const ChatInputField({super.key, required this.onSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppColors.transparent, // Floating capsule feel
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 20.h + MediaQuery.of(context).padding.bottom,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              constraints: BoxConstraints(minHeight: 54.h),
              decoration: BoxDecoration(
                color: AppColors.whiteBg,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.primary
                      : AppColors.border,
                  width: _isFocused ? 1.5.w : 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDarkMode
                              ? AppColors.black.withValues(alpha: 0.35)
                              : AppColors.primary.withValues(alpha: 0.04)),
                    blurRadius: _isFocused ? 16 : 8,
                    spreadRadius: _isFocused ? 1 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: TextDirection
                    .ltr, // Lock Send to left and field/AI icon to right
                child: Row(
                  children: [
                    // Send Button with active bounce-scale and premium glow
                    Padding(
                      padding: EdgeInsets.all(6.w),
                      child: GestureDetector(
                        onTap: _handleSend,
                        child: AnimatedScale(
                          scale: hasText ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: hasText
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.chatUserBubbleStart,
                                        AppColors.chatUserBubbleEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        AppColors.chatInputButtonDisabledStart,
                                        AppColors.chatInputButtonDisabledEnd,
                                      ],
                                    ),
                              boxShadow: hasText
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                hasText
                                    ? 'assets/send_but_green.svg'
                                    : 'assets/send_but.svg',
                                width: 20.w,
                                height: 20.w,
                                colorFilter: ColorFilter.mode(
                                  hasText
                                      ? AppColors.white
                                      : (isDarkMode
                                            ? AppColors.white.withValues(alpha: 0.38)
                                            : AppColors.black.withValues(alpha: 0.38)),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
 
                    // Input Text Field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اكتب سؤالك هنا......',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.inputHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 14.h,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
 
                    // AI Assist Star Icon (Far Right)
                    Padding(
                      padding: EdgeInsets.only(right: 18.w, left: 4.w),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 18.w,
                        color: _isFocused
                            ? AppColors.primary
                            : AppColors.greyIcon,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
