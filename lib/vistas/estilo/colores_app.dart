import 'package:flutter/material.dart';

class ColoresApp {
  ColoresApp._();

  // Paleta principal del Banco de Sangre
  static const Color primario = Color(0xFFD32F2F);
  static const Color fondoPantalla = Color(0xFFF5F5F5);
  static const Color superficieTarjeta = Colors.white;
  static const Color sombraTarjeta = Colors.black26;

  // Textos e íconos
  static const Color textoPrincipal = Color(0xFF212121);
  static const Color textoSecundario = Color(0xFF757575);
  static const Color textoSobrePrimario = Colors.white;

  // Estados de botones deshabilitados
  static const Color botonDeshabilitadoFondo = Color(0xFFE0E0E0);
  static const Color botonDeshabilitadoTexto = Color(0xFF757575);

  // Estados semánticos (SnackBars y alertas)
  static const Color exito = Color(0xFF388E3C);
  static const Color error = Color(0xFFD32F2F);
}