import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_principal.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Gestión de Sangre',
      home: PantallaPrincipal(),
    );
  }
}