// path: lib/features/home/presentation/widgets/search_suggestions_list.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/home/models/search_suggestion_model.dart';

class SearchSuggestionsList extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final ValueChanged<SearchSuggestion> onSuggestionSelected;

  const SearchSuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(
            'عذراً، لم نجد نتائج مطابقة لمصطلح البحث.',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13.sp,
              color: AppColors.slateGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.inputFieldBg, height: 1.h),
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => onSuggestionSelected(item),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: item.category == 'رخصة القيادة'
                        ? AppColors.successLight
                        : AppColors.infoBlueBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: item.category == 'رخصة القيادة'
                          ? AppColors.darkGreen
                          : AppColors.infoBlueText,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13.sp,
                      color: AppColors.infoBlueDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12.r,
                  color: AppColors.lightGreyBorder,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
