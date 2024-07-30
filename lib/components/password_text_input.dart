import 'package:flutter/material.dart';

class PasswordTextInput extends StatefulWidget {
  final TextEditingController textEditingControllerHere;
  final String labelTextHere;
  final String? Function(String?)? validator;

  const PasswordTextInput({super.key,
    required this.textEditingControllerHere,
    required this.labelTextHere,
    this.validator,
  });

  @override
  State<StatefulWidget> createState() => _PasswordTextInputState();
}

class _PasswordTextInputState extends State<PasswordTextInput> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingControllerHere,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelTextHere,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
      validator: widget.validator,
    );
  }
}
