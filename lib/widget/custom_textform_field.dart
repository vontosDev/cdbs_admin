import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final Widget label; // The original label
  final TextStyle labelStyle;
  final TextEditingController controller;
  final bool isNumeric;
  final bool isEmail; // New property for email validation
  final bool isRead;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final bool isObscure;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.labelStyle,
    required this.controller,
    required this.isNumeric,
    this.isEmail = false, // Default to false
    this.isRead = false,
    this.validator,
    this.maxLength,
    this.isObscure = false,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  String? errorMessage; // Initialize to null

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (BuildContext context) {
          return TextFormField(
            cursorColor: const Color(0xff012169),
            controller: widget.controller,
            readOnly: widget.isRead,
            style: const TextStyle(color: Color(0xff012169)),
            keyboardType: widget.isNumeric
                ? TextInputType.number
                : (widget.isEmail ? TextInputType.emailAddress : TextInputType.text),
            inputFormatters: widget.isNumeric
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ]
                : (widget.isEmail
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9@._-]*')),
                      ]
                    : <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r"^[a-zA-Z\s'\-]*")), // Allow only letters and spaces
                      ]),
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              labelText: errorMessage ?? _getLabelText(), // Get label text or error message
              labelStyle: widget.labelStyle.copyWith(
                color: errorMessage != null ? const Color(0xffC8102E).withOpacity(0.5) : widget.labelStyle.color,
              ),
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Focus.of(context).hasFocus
                      ? const Color(0xff012169)
                      : const Color(0xff222222),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: Color(0xff012169),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: errorMessage != null ? const Color(0xffC8102E) : const Color(0xff222222).withOpacity(0.35),
                  width: 1.0,
                ),
              ),
            ),
            obscureText: widget.isObscure,
            onChanged: (value) {
              // Clear error message on change
              if (errorMessage != null) {
                setState(() {
                  errorMessage = null;
                });
              }
            },
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                errorMessage = error; // Update error message state
              });
              return null; // Return null to avoid showing default validator messages
            },
          );
        },
      ),
    );
  }

  String? _getLabelText() {
    if (widget.label is Row) {
      final row = widget.label as Row;
      if (row.children.isNotEmpty && row.children.first is Text) {
        return (row.children.first as Text).data; // Get text from the first Text widget
      }
    }
    return null; // Fallback if label structure is different
  }
}

