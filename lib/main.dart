import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_principal.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final registroDonantes = RegistroDonantes();
    final registroDonacion = RegistroDonacion();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Gestión de Sangre',
      home: PantallaPrincipal(
        registroDonantes: registroDonantes,
        registroDonacion: registroDonacion,
      ),
    );
  }
}