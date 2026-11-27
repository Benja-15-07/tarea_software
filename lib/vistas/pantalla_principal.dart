import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/enums/rol.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/registro_despacho.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/registro_usuarios.dart';
import 'package:proyecto_banco_sangre/logica/solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/usuario.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_generar_despacho.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_historial_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inicio_sesion.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inventario_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_solicitud_despacho.dart';

class PantallaPrincipal extends StatefulWidget {
  final RegistroDonantes? registroDonantes;
  final RegistroDonacion? registroDonacion;
  final RegistroUsuarios? registroUsuarios;

  const PantallaPrincipal({
    super.key,
    this.registroDonantes,
    this.registroDonacion,
    this.registroUsuarios,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  Rol? _rolActual;

  late final RegistroDonantes _registroDonantes;
  late final RegistroDonacion _registroDonacion;
  late final RegistroUsuarios _registroUsuarios;
  late final RegistroSolicitudDespacho _registroSolicitudDespacho;
  late final RegistroDespacho _registroDespacho;
  late final SolicitudDespacho _solicitudDePrueba;

  @override
  void initState() {
    super.initState();
    _registroDonantes = widget.registroDonantes ?? RegistroDonantes();
    _registroDonacion = widget.registroDonacion ?? RegistroDonacion();
    _registroUsuarios = widget.registroUsuarios ?? RegistroUsuarios();
    _registroSolicitudDespacho = RegistroSolicitudDespacho(
      registroDonacion: _registroDonacion,
    );
    _registroDespacho = RegistroDespacho(registroDonacion: _registroDonacion);

    // Usuario de prueba para poder iniciar sesión desde la app
    _registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "juan",
        contrasena: "secreto123",
        rol: Rol.gestorInventario,
      ),
    );
    _registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "receptor",
        contrasena: "secreto123",
        rol: Rol.receptorDonaciones,
      ),
    );
    _registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "hospital",
        contrasena: "secreto123",
        rol: Rol.funcionarioHospital,
      ),
    );

    // Donaciones de prueba para que el stock no esté vacío
    _registroDonacion.ingresarDonacion(
      tipoSangre: TipoSangre.oPositivo,
      volumenDonado: 450,
      fechaDeToma: DateTime.now().subtract(const Duration(days: 5)),
      rutDonante: "12345678-5",
    );
    _registroDonacion.ingresarDonacion(
      tipoSangre: TipoSangre.oPositivo,
      volumenDonado: 450,
      fechaDeToma: DateTime.now().subtract(const Duration(days: 3)),
      rutDonante: "12345678-5",
    );

    // Solicitud de prueba para poder entrar a PantallaGenerarDespacho
    _solicitudDePrueba = SolicitudDespacho(
      id: "9000001",
      unidadesSolicitadas: {TipoSangre.oPositivo: 2},
      tipoDespacho: TipoDespacho.normal,
      stockDisponible: {TipoSangre.oPositivo: 2},
    );
  }

  void _onLoginExitoso(Rol rol) {
    setState(() {
      _rolActual = rol;
      _indiceActual = 0;
    });
  }

  void _cerrarSesion() {
    setState(() {
      _rolActual = null;
      _indiceActual = 0;
    });
  }

  List<Widget> _pantallasPorRol(Rol rol) {
    switch (rol) {
      case Rol.receptorDonaciones:
        return [
          PantallaRegistroDonantes(registroDonantes: _registroDonantes),
          PantallaRegistroDonaciones(
            registroDonacion: _registroDonacion,
            registroDonantes: _registroDonantes,
          ),
        ];
      case Rol.gestorInventario:
        return [
          PantallaInventarioDonaciones(registroDonacion: _registroDonacion),
          PantallaHistorialDonaciones(registroDonacion: _registroDonacion),
          PantallaGenerarDespacho(
            solicitud: _solicitudDePrueba,
            registroDespacho: _registroDespacho,
          ),
        ];
      case Rol.funcionarioHospital:
        return [
          PantallaSolicitudDespacho(
            registroSolicitudDespacho: _registroSolicitudDespacho,
          ),
        ];
    }
  }

  List<BottomNavigationBarItem> _itemsPorRol(Rol rol) {
    switch (rol) {
      case Rol.receptorDonaciones:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'Donantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines),
            label: 'Donaciones',
          ),
        ];
      case Rol.gestorInventario:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Despachar',
          ),
        ];
      case Rol.funcionarioHospital:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Solicitar',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rolActual == null) {
      return PantallaInicioSesion(
        registroUsuarios: _registroUsuarios,
        onLoginExitoso: _onLoginExitoso,
      );
    }

    final rol = _rolActual!;
    final pantallas = _pantallasPorRol(rol);
    final items = _itemsPorRol(rol);
    final mostrarBarra = items.length > 1;

    return Scaffold(
      body: pantallas[_indiceActual],
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton_cerrar_sesion'),
        onPressed: _cerrarSesion,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
      ),
      bottomNavigationBar: mostrarBarra
          ? BottomNavigationBar(
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
              items: items,
            )
          : null,
    );
  }
}
