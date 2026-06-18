// path: lib/features/home/presentation/widgets/home_search_field.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/home/bloc/home_search_bloc.dart';
import 'package:traffic/features/home/bloc/home_search_event_state.dart';
import 'search_navigation_helper.dart';
import 'search_suggestions_list.dart';

class HomeSearchField extends StatefulWidget {
  const HomeSearchField({super.key});

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _onTextChanged() {
    context.read<HomeSearchBloc>().add(SearchQueryChanged(_controller.text));
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size(double.infinity, 48.h);

    return OverlayEntry(
      builder: (_) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8.h),
            child: Material(
              color: Colors.transparent,
              child: TapRegion(
                onTapOutside: (_) {
                  _focusNode.unfocus();
                },
                child: Container(
                  constraints: BoxConstraints(maxHeight: 280.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.inputFieldBg, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: BlocBuilder<HomeSearchBloc, HomeSearchState>(
                      bloc: BlocProvider.of<HomeSearchBloc>(context),
                      builder: (blocContext, state) {
                        if (state is HomeSearchLoading) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (state is HomeSearchSuccess) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 16.w, left: 16.w, top: 12.h, bottom: 6.h),
                                child: Text(
                                  state.query.isEmpty ? 'الخدمات الأكثر طلباً ✨' : 'نتائج البحث 🔍',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slateGrey,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: SearchSuggestionsList(
                                  suggestions: state.suggestions,
                                  onSuggestionSelected: (item) {
                                    _focusNode.unfocus();
                                    _controller.clear();
                                    context.read<HomeSearchBloc>().add(const SearchQueryChanged(''));
                                    SearchNavigationHelper.navigateToService(context, item.serviceType);
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        if (state is HomeSearchFailure) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Text(
                                state.errorMessage,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14.sp,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'ما الخدمة التي تريدها؟',
            hintTextDirection: TextDirection.rtl,
            hintStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Icon(
                Icons.search,
                color: AppColors.slateGrey,
                size: 22.sp,
              ),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      color: AppColors.slateGrey,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      _controller.clear();
                    },
                  )
                : null,
            suffixIconConstraints: BoxConstraints(
              minHeight: 22.sp,
              minWidth: 34.w,
            ),
          ),
        ),
      ),
    );
  }
}
