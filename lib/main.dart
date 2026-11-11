import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donantes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final registroDonantes = RegistroDonantes();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Gestión de Sangre',
      home: PantallaRegistroDonantes(registroDonantes: registroDonantes),
    );
  }
}