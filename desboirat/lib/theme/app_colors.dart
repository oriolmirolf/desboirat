import 'package:flutter/material.dart';

class AppColors {
  // 1. The Palette (Private to this class effectively, or public if you need raw access)
  static const Color skyBlue = Color(0xFF92CBE5);
  static const Color mintGreen = Color(0xFFCDE8CD);
  static const Color cream = Color(0xFFFEFEF4);
  static const Color deepSlate = Color(0xFF4A6C77);

  // 2. Gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue, mintGreen],
  );
}