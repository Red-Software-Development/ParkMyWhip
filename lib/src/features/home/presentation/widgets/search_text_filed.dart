import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.searchActiveHint,
  });

  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String searchActiveHint;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      style: AppTextStyles.urbanistFont12BlackBold1_2,
      decoration: InputDecoration(
        hintText: isFocused ? widget.searchActiveHint : widget.hintText,
        hintStyle: AppTextStyles.urbanistFont11Gray30Regular1_24,
        filled: true,
        fillColor: AppColor.gray10,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColor.black),
        ),

        suffixIcon: hasText
            ? IconButton(
                icon: CircleAvatar(
                  backgroundColor: AppColor.white,
                  radius: 12,
                  child: Icon(
                    TowMyWhipIcons.close,
                    size: 12,
                    color: AppColor.black,
                  ),
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
            : Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(
                  TowMyWhipIcons.searchIcon,
                  size: 14,
                  color: AppColor.redDark,
                ),
              ),

        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }
}
