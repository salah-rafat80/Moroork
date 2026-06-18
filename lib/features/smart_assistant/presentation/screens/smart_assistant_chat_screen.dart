import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/widgets/app_drawer.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';
import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/features/smart_assistant/presentation/widgets/chat_bubble.dart';
import 'package:traffic/features/smart_assistant/presentation/widgets/chat_input_field.dart';
import 'package:traffic/features/smart_assistant/presentation/widgets/ai_thinking_indicator.dart';
import 'package:traffic/injection_container.dart';
import '../../bloc/smart_assistant_chat_bloc.dart';
import '../../bloc/smart_assistant_chat_event_state.dart';

/// Chat screen for the smart assistant feature.
///
/// Matches the provided design:
///   – AppBar: "محادثة المساعد الذكي" with hamburger + back arrow
///   – Messages list (bot greeting + user/bot conversation)
///   – Bottom input field with green send button
class SmartAssistantChatScreen extends StatefulWidget {
  const SmartAssistantChatScreen({super.key});

  @override
  State<SmartAssistantChatScreen> createState() =>
      _SmartAssistantChatScreenState();
}

class _SmartAssistantChatScreenState extends State<SmartAssistantChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late final SmartAssistantChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<SmartAssistantChatBloc>();
    _chatBloc.add(const WelcomingMessageFetched());
  }

  void _onSend(String text) {
    if (text.trim().isEmpty) return;
    _chatBloc.add(MessageSent(text));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.lightGreyBg,
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // ── App bar ──
            ServiceScreenAppBar(
              title: 'محادثة المساعد الذكي',
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            SizedBox(height: 5.h),

            // ── Messages list or Loading/Failure States ──
            Expanded(
              child: BlocConsumer<SmartAssistantChatBloc, SmartAssistantChatState>(
                listener: (context, state) {
                  // If new message or loading state, scroll to bottom
                  _scrollToBottom();
                  if (state is SmartAssistantChatFailure && state.messages.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: AppColors.redError,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is SmartAssistantChatLoading;

                  // Initial loading or connection phase (no messages loaded yet)
                  if (state.messages.isEmpty) {
                    if (state is SmartAssistantChatFailure) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 60.w,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'عذراً، فشل الاتصال بالمساعد الذكي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _chatBloc.add(const WelcomingMessageFetched());
                                },
                                icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
                                label: const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Centered loader when we are connecting initially
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomLoadingIndicator(
                            width: 110.w,
                            height: 110.h,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'جاري الاتصال بالمساعد الذكي...',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'يرجى الانتظار قليلاً لبدء المحادثة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Message history is loaded
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    itemCount: state.messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show thinking indicator at the bottom if currently loading the AI's reply
                      if (index == state.messages.length && isLoading) {
                        return const AiThinkingIndicator();
                      }

                      final msg = state.messages[index];
                      return ChatBubble(text: msg.text, isUser: msg.isUser);
                    },
                  );
                },
              ),
            ),

            // ── Input field ──
            ChatInputField(onSend: _onSend),
          ],
        ),
      ),
    );
  }
}
