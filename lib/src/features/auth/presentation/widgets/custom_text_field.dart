import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.onChanged,
  });

  final String title;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final void Function(String)? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // Get error from validator prop (from cubit state)
    final errorMessage = widget.validator?.call(widget.controller?.text);
    final hasError = errorMessage != null && errorMessage.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: AppTextStyles.urbanistFont14Grey700Regular1_28,
        ),
        verticalSpace(4),

        // Text Field
        TextFormField(
          obscuringCharacter: '⦁',
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscureText,
          style: AppTextStyles.urbanistFont16Grey800Regular1_3,
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.urbanistFont16Grey800Opacity40Regular1_3,
            contentPadding: EdgeInsets.all(12.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.grey300, width: 1.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: hasError ? AppColor.red500 : AppColor.grey300,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: hasError ? AppColor.red500 : AppColor.grey800,
                width: 1.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.red500, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.red500, width: 1.w),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: hasError ? AppColor.red500 : AppColor.grey400,
                      size: 20.w,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),

        // Error Message
        if (hasError) ...[
          verticalSpace(4),
          Text(
            errorMessage,
            style: AppTextStyles.urbanistFont12Red500Regular1_5,
          ),
        ],
      ],
    );
  }
}
