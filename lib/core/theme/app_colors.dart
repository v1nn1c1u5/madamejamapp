import 'package:flutter/material.dart';

/// Paleta da identidade visual do Madame Jam.
///
/// Referência: logomarca e mascote da loja (UX-DR1 do PRD/Arquitetura).
/// Estilo clean e sofisticado — champagne/bege sobre off-white, com carvão
/// para texto e contraste.
abstract final class AppColors {
  // Cores de marca
  static const Color champagne = Color(0xFFC4A882);
  static const Color offWhite = Color(0xFFF5F0EA);
  static const Color charcoal = Color(0xFF2C2C2C);

  // Variações derivadas (tons de apoio)
  static const Color champagneDark = Color(0xFFA8895F);
  static const Color champagneLight = Color(0xFFE4D6BF);
  static const Color cream = Color(0xFFFBF8F3);

  // Neutros
  static const Color charcoalSoft = Color(0xFF55504A);
  static const Color border = Color(0xFFE5DCCE);
  static const Color white = Color(0xFFFFFFFF);

  // Semânticos
  static const Color success = Color(0xFF4E7C59);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFFC98A2B);
}
