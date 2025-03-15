import 'package:flutter/material.dart';

InputDecoration textBoxStyle(String hintText, String label) {
  return InputDecoration(
    hintText: hintText,
    labelText: label,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
    ),
  );
}

TextStyle myTextStyle() {
  return const TextStyle(
    fontSize: 20.0,
    color: Colors.red,
    fontWeight: FontWeight.bold,
  );
}

InputDecoration greenInputDecoration(String labelText, String hintText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: Color(0xFF00A87E)),
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF00A87E)),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF00A87E), width: 2.0),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF00A87E), width: 2.0),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ),
    suffixIconColor: const Color(0xFF00A87E),
  );
}
