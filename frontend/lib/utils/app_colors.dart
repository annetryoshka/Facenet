import 'package:flutter/material.dart';

class AppColors {
  // Colores principales - Elegante y formal
  static const Color primary = Color(0xFF2D3E50);      // Gris oscuro profesional
  static const Color secondary = Color(0xFF34495E);    // Gris acero
  static const Color accent = Color(0xFFF39C12);       // Dorado elegante
  static const Color accentLight = Color(0xFFFDB913);  // Dorado claro
  static const Color success = Color(0xFF27AE60);      // Verde profesional
  static const Color error = Color(0xFFE74C3C);        // Rojo elegante
  static const Color warning = Color(0xFFF39C12);      // Dorado (mismo que accent)

  // Grises claros y profesionales
  static const Color background = Color(0xFFF8F9FA);   // Gris muy claro
  static const Color surface = Color(0xFFFFFFFF);      // Blanco puro
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color outline = Color(0xFFDEE2E6);
  static const Color outlineVariant = Color(0xFFCED4DA);

  // Texto - Tonos grises profesionales
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textTertiary = Color(0xFFBDC3C7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Superficies adicionales
  static const Color cardBackground = Color(0xFFFAFBFC);
  static const Color dividerColor = Color(0xFFECF0F1);

  // Dark mode - Grises oscuros elegantes
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkSurfaceVariant = Color(0xFF3A3A3A);

  // Gradientes profesionales
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D3E50), Color(0xFF34495E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFFDB913)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}