import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// A single chat message bubble with entrance animation and refined styling.
class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _linkify(String text) {
    final RegExp urlRegExp = RegExp(
      r'(?<!\]\()(https?:\/\/[^\s\)]+|www\.[^\s\)]+)',
      caseSensitive: false,
    );
    return text.replaceAllMapped(urlRegExp, (match) {
      final url = match.group(1)!;
      final href = url.startsWith('www.') ? 'https://$url' : url;
      return '[$url]($href)';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
          child: Align(
            alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isUser && !isRtl) ...[
                  _buildAiAvatar(),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 270.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: widget.isUser ? null : AppColors.whiteBg,
                      gradient: widget.isUser
                          ? LinearGradient(
                              colors: [AppColors.chatUserBubbleStart, AppColors.chatUserBubbleEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isUser
                              ? AppColors.chatUserBubbleStart.withValues(alpha: 0.2)
                              : (isDarkMode 
                                  ? AppColors.black.withValues(alpha: 0.25)
                                  : AppColors.shadowColor.withValues(alpha: 0.06)),
                          blurRadius: widget.isUser ? 10 : 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: widget.isUser ? Radius.circular(16.r) : Radius.zero,
                        bottomRight: widget.isUser ? Radius.zero : Radius.circular(16.r),
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: MarkdownBody(
                        data: _linkify(widget.text),
                        onTapLink: (text, href, title) async {
                          final String urlPath = href ?? text;
                          if (urlPath.isNotEmpty) {
                            try {
                              final Uri url = Uri.parse(urlPath);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (!urlPath.startsWith('http://') && !urlPath.startsWith('https://')) {
                                  final Uri fallbackUrl = Uri.parse('https://$urlPath');
                                  if (await canLaunchUrl(fallbackUrl)) {
                                    await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
                                  }
                                }
                              }
                            } catch (_) {}
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                            height: 1.5,
                          ),
                          strong: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          listBullet: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          h1: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          h2: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          h3: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          h4: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          em: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontStyle: FontStyle.italic,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          a: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          code: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13.sp,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                            backgroundColor: widget.isUser 
                                ? AppColors.white.withValues(alpha: 0.15) 
                                : AppColors.lightGreyBg,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: widget.isUser 
                                ? AppColors.white.withValues(alpha: 0.1) 
                                : AppColors.lightGreyBg,
                            borderRadius: BorderRadius.circular(8.r),
                            border: widget.isUser 
                                ? null 
                                : Border.all(color: AppColors.border),
                          ),
                          codeblockPadding: EdgeInsets.all(8.w),
                          blockquote: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: widget.isUser 
                                ? AppColors.white.withValues(alpha: 0.9) 
                                : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: widget.isUser 
                                ? AppColors.white.withValues(alpha: 0.08) 
                                : AppColors.lightGreyBg,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border(
                              right: BorderSide(
                                color: widget.isUser ? AppColors.white : AppColors.primary,
                                width: 4.w,
                              ),
                            ),
                          ),
                          blockquotePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          tableBody: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          tableHead: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.isUser ? AppColors.white : AppColors.textPrimary,
                          ),
                          tableBorder: TableBorder.all(
                            color: widget.isUser 
                                ? AppColors.white.withValues(alpha: 0.3) 
                                : AppColors.border,
                            width: 1.w,
                          ),
                          tableCellsPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                          blockSpacing: 6.h,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.isUser && isRtl) ...[
                  SizedBox(width: 8.w),
                  _buildAiAvatar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/ai_robot.svg',
          width: 20.w,
          height: 20.w,
        ),
      ),
    );
  }
}
