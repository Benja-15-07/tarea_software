import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_banco_sangre/vistas/pantalla_solicitudes_despacho.dart';
import 'package:proyecto_banco_sangre/logica/solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_despacho.dart';

void main() {
  //tipo de sangre utilizado para construir las solicitudes de prueba
  final tipoSangre = TipoSangre.values.first;

  //crea una solicitud de despacho con los datos indicados
  SolicitudDespacho crearSolicitud({
    required String id,
    required DateTime fecha,
    required TipoDespacho tipo,
    bool aceptada = false,
  }) {
    final solicitud = SolicitudDespacho(
      id: id,
      unidadesSolicitadas: {tipoSangre: 1},
      tipoDespacho: tipo,
      stockDisponible: {tipoSangre: 10},
      fechaSolicitud: fecha,
    );

    // Por defecto todas las solicitudes son pendientes.
    // Si se solicita una aprobada, se actualiza su estado.
    if (aceptada) {
      solicitud.actualizarEstado(EstadoSolicitud.aceptada);
    }

    return solicitud;
  }

  RegistroSolicitudDespacho crearRegistroSolicitudes() {
    final registroDonacion = RegistroDonacion();

    // Agregar una donación para disponer de stock.
    registroDonacion.ingresarDonacion(
      tipoSangre: tipoSangre,
      volumenDonado: 450,
      fechaDeToma: DateTime(2026, 11, 15),
      rutDonante: 'RUT_VALIDO',
    );

    final ids = ['SOL-001', 'SOL-002', 'SOL-003', 'SOL-004'];
    int indice = 0;

    return RegistroSolicitudDespacho(
      registroDonacion: registroDonacion,
      generarId: () => ids[indice++],
    );
  }

  // Construye la pantalla que será utilizada en los tests.
  Widget construirPantalla(
    RegistroSolicitudDespacho registroSolicitudDespacho,
    RegistroDespacho registroDespacho,
  ) {
    return MaterialApp(
      home: PantallaSolicitudesDespacho(
        registroSolicitudDespacho: registroSolicitudDespacho,
        registroDespacho: registroDespacho,
      ),
    );
  }

  // Expande las dos categorías de solicitudes.
  Future<void> expandirCategorias(WidgetTester tester) async {
    await tester.tap(find.text('Despacho urgente'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Despacho normal'));
    await tester.pumpAndSettle();
  }

  group('PantallaSolicitudesDespacho', () {
    // TEST 1:
    // Visualizar listado de solicitudes de despacho pendientes
    testWidgets('Muestra las solicitudes pendientes ordenadas por fecha', (
      WidgetTester tester,
    ) async {
      final registro = crearRegistroSolicitudes();
      final registroDespacho = RegistroDespacho(
        registroDonacion: RegistroDonacion(),
      );

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 20),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 18),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 22),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.normal,
        fechaSolicitud: DateTime(2026, 11, 19),
      );

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      await expandirCategorias(tester);

      // Comprobar que se muestran todas las solicitudes.
      expect(find.text('Solicitud #SOL-001'), findsOneWidget);
      expect(find.text('Solicitud #SOL-002'), findsOneWidget);
      expect(find.text('Solicitud #SOL-003'), findsOneWidget);
      expect(find.text('Solicitud #SOL-004'), findsOneWidget);

      // Comprobar que se muestran las fechas.
      expect(find.textContaining('2026-11-20'), findsOneWidget);

      expect(find.textContaining('2026-11-18'), findsOneWidget);

      expect(find.textContaining('2026-11-22'), findsOneWidget);

      expect(find.textContaining('2026-11-19'), findsOneWidget);

      // Comprobar el orden cronológico de las solicitudes urgentes.
      // La solicitud más antigua debe aparecer primero.

      final posicionSOL002 = tester
          .getTopLeft(find.text('Solicitud #SOL-002'))
          .dy;

      final posicionSOL001 = tester
          .getTopLeft(find.text('Solicitud #SOL-001'))
          .dy;

      final posicionSOL003 = tester
          .getTopLeft(find.text('Solicitud #SOL-003'))
          .dy;

      expect(posicionSOL002, lessThan(posicionSOL001));

      expect(posicionSOL001, lessThan(posicionSOL003));
    });

    // TEST 2:
    // Visualizar listado vacio cuando no existen solicitudes pendientes
    testWidgets('Muestra un mensaje cuando no existen solicitudes pendientes', (
      WidgetTester tester,
    ) async {
      final registro = crearRegistroSolicitudes();
      final registroDespacho = RegistroDespacho(
        registroDonacion: RegistroDonacion(),
      );

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 20),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.normal,
        fechaSolicitud: DateTime(2026, 11, 21),
      );

      registro.actualizarEstadoSolicitud('SOL-001', EstadoSolicitud.aceptada);
      registro.actualizarEstadoSolicitud('SOL-002', EstadoSolicitud.aceptada);

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      await expandirCategorias(tester);

      // Comprobar que no se muestran solicitudes.
      expect(find.text('Solicitud #SOL-001'), findsNothing);
      expect(find.text('Solicitud #SOL-002'), findsNothing);

      // Comprobar que se muestra el mensaje informativo.
      expect(
        find.text('No hay solicitudes de despacho pendientes'),
        findsNWidgets(2),
      );
    });

    // TEST 3:
    // No mostrar solicitudes con estados distintos de pendiente
    testWidgets('Muestra únicamente las solicitudes pendientes', (
      WidgetTester tester,
    ) async {
      final registro = crearRegistroSolicitudes();
      final registroDespacho = RegistroDespacho(
        registroDonacion: RegistroDonacion(),
      );

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 18),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.normal,
        fechaSolicitud: DateTime(2026, 11, 19),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 20),
      );

      registro.ingresarSolicitud(
        unidadesSolicitadas: {tipoSangre: 1},
        tipoDespacho: TipoDespacho.normal,
        fechaSolicitud: DateTime(2026, 11, 21),
      );

      // Se actualizan los estados de las solicitudes aceptadas.
      registro.actualizarEstadoSolicitud('SOL-002', EstadoSolicitud.aceptada);
      registro.actualizarEstadoSolicitud('SOL-004', EstadoSolicitud.aceptada);

      await tester.pumpWidget(construirPantalla(registro, registroDespacho));

      await expandirCategorias(tester);

      // Las solicitudes pendientes deben aparecer.
      expect(find.text('Solicitud #SOL-001'), findsOneWidget);
      expect(find.text('Solicitud #SOL-003'), findsOneWidget);

      // Las solicitudes aceptadas no deben aparecer.
      expect(find.text('Solicitud #SOL-002'), findsNothing);
      expect(find.text('Solicitud #SOL-004'), findsNothing);
    });
  });
}
