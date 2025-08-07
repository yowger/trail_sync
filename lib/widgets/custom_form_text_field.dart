import 'package:flutter/material.dart';

class CustomFormTextField extends StatelessWidget {
  const CustomFormTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    this.obscure = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.autofillHints,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final bool obscure;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final borderColor = focusNode.hasFocus
        ? const Color(0xFFDADADA)
        : const Color(0xffc5c5c5);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure ? !isPasswordVisible : false,
      obscuringCharacter: '*',
      autofillHints: autofillHints,
      validator: validator,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          color: focusNode.hasFocus
              ? Colors.grey.shade700
              : Colors.grey.shade500,
        ),
        suffixIcon: obscure
            ? GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: focusNode.hasFocus
                      ? Colors.grey.shade700
                      : Colors.grey.shade400,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      ),
    );
  }
}
