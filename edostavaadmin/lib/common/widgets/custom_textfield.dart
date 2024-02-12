import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final int? maxLines;
  final Icon? icon;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.label,
    this.maxLines,
    this.obscureText = false,
    this.icon,
    this.validator,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                const TextStyle(color: Colors.black26, letterSpacing: 1.2),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                width: 3,
                color: Colors.black38,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black38,
                width: 3,
              ),
            ),
          ),
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}
