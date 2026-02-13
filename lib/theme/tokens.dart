import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFFC9A24D);
  static const ink = Color(0xFF0B0B0F);
  static const surface = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF6F6F8);
  static const divider = Color(0xFFE7E7EC);
  static const muted = Color(0xFF6B6B75);
  static const success = Color(0xFF1E8E3E);
  static const warning = Color(0xFFB26A00);
  static const danger = Color(0xFFC62828);
  static const info = Color(0xFF1A73E8);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

class AppRadii {
  static const card = 12.0;
  static const sheet = 16.0;
  static const pill = 999.0;
}

class AppTextStyles {
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink,
  );
  static const bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.muted,
  );
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.ink,
  );
}
