import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inventario_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_solicitud_despacho.dart';

class PantallaPrincipal extends StatefulWidget {
  final RegistroDonantes? registroDonantes;
  final RegistroDonacion? registroDonacion;
  final RegistroSolicitudDespacho? registroSolicitudDespacho;

  const PantallaPrincipal({
    super.key,
    this.registroDonantes,
    this.registroDonacion,
    this.registroSolicitudDespacho,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  late final RegistroDonantes _registroDonantes;
  late final RegistroDonacion _registroDonacion;
  late final RegistroSolicitudDespacho _registroSolicitudDespacho;

  @override
  void initState() {
    super.initState();
    // Se instancian una sola vez para conservar los datos al navegar entre pestañas
    _registroDonantes = widget.registroDonantes ?? RegistroDonantes();
    _registroDonacion = widget.registroDonacion ?? RegistroDonacion();
    _registroSolicitudDespacho =
        widget.registroSolicitudDespacho ??
        RegistroSolicitudDespacho(registroDonacion: _registroDonacion);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      PantallaRegistroDonantes(registroDonantes: _registroDonantes),
      PantallaRegistroDonaciones(
        registroDonacion: _registroDonacion,
        registroDonantes: _registroDonantes,
      ),
      PantallaInventarioDonaciones(registroDonacion: _registroDonacion),
      PantallaSolicitudDespacho(
        registroSolicitudDespacho: _registroSolicitudDespacho,
      ),
    ];

    return Scaffold(
      body: pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        key: const Key('barra_navegacion_principal'),
        currentIndex: _indiceActual,
        onTap: (nuevoIndice) {
          setState(() {
            _indiceActual = nuevoIndice;
          });
        },
        backgroundColor: ColoresApp.superficieTarjeta,
        selectedItemColor: ColoresApp.primario,
        unselectedItemColor: ColoresApp.textoSecundario,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'Donantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines),
            label: 'Donaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Solicitudes',
          ),
        ],
      ),
    );
  }
}