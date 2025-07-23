import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? optionalLeadingIcon;
  final IconData? optionalTrailingIcon;
  final Function(String)? onChanged;
  final bool isObscure;
  final bool isOptionalLeadingIcon;
  final FormFieldValidator<String>? validator;
  final TextInputType? inputType;
  final bool? readOnly;
  final Function()? onTap;



  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.optionalLeadingIcon,
      this.optionalTrailingIcon,
        required this.isOptionalLeadingIcon,
        this.onChanged,
      this.isObscure = false,
      this.validator,
        this.inputType,
        this.readOnly,
        this.onTap,
      });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}




class _CustomTextFieldState extends State<CustomTextField> {
  // bool isOptionalLeadingIcon = false;
  bool isPasswordVisible = false;

  void showPassword(){
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 38,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.smallTextRegular(context),
          prefixIcon: Icon(widget.isOptionalLeadingIcon ? widget.optionalLeadingIcon : null, color: Colors.black, size: 16,),
          suffixIcon: widget.isObscure ? GestureDetector(
            onTap: showPassword,
            child: isPasswordVisible ? Icon(Icons.visibility_off, size: 16, color: Theme.of(context).colorScheme.tertiary,) : Icon(Icons.visibility, size: 16, color: Theme.of(context).colorScheme.tertiary,),
          ) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: 1,
              ),
            ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface
        ),
        obscureText: widget.isObscure && !isPasswordVisible,
        onChanged: widget.onChanged,
        keyboardType: widget.inputType,
        readOnly: widget.readOnly ?? false,
        onTap: widget.onTap,
      ),
    );
  }
}
