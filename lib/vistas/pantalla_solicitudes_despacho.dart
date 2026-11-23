import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';

class PantallaSolicitudesDespacho extends StatefulWidget {
  const new({super.key});

  @override
  State<PantallaSolicitudesDespacho> createState() => _PantallaSolicitudesDespachoState();
}

class _PantallaSolicitudesDespachoState extends State<PantallaSolicitudesDespacho> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Solicitudes de despacho"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("placeholder")
      ),
    );
  }
}