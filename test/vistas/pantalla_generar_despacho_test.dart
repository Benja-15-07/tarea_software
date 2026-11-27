import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_despacho.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_generar_despacho.dart";

void main() {
  group("Pruebas de interfaz de generación de despacho (T16)", () {
    testWidgets(
      "Prueba 1: Confirmar generación de despacho muestra comprobante y actualiza estado a Despachada",
      (tester) async {
        final registroDonacion = RegistroDonacion();
        final registroDespacho = RegistroDespacho(
          registroDonacion: registroDonacion,
        );
        final hoy = DateTime.now();

        final idUnidad1 = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 5)),
          rutDonante: "11111111-1",
        );
        final idUnidad2 = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 3)),
          rutDonante: "22222222-2",
        );

        final solicitud = SolicitudDespacho(
          id: "9000001",
          unidadesSolicitadas: {TipoSangre.oPositivo: 2},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: {TipoSangre.oPositivo: 2},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: PantallaGenerarDespacho(
              solicitud: solicitud,
              registroDespacho: registroDespacho,
            ),
          ),
        );

        expect(find.text("Pendiente"), findsOneWidget);

        await tester.tap(find.byKey(const Key("boton_generar_despacho")));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("comprobante_despacho")), findsOneWidget);
        expect(find.text("ID Despacho:"), findsOneWidget);
        expect(find.text("Fecha de despacho:"), findsOneWidget);
        expect(find.textContaining(idUnidad1), findsOneWidget);
        expect(find.textContaining(idUnidad2), findsOneWidget);
        expect(find.text("Despachada"), findsOneWidget);
        expect(solicitud.estadoSolicitud, EstadoSolicitud.despachada);
      },
    );

    testWidgets(
      "Prueba 2: Muestra alerta por falta de stock y mantiene la solicitud en Pendiente",
      (tester) async {
        final registroDonacion = RegistroDonacion();
        final registroDespacho = RegistroDespacho(
          registroDonacion: registroDonacion,
        );
        final hoy = DateTime.now();

        registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.abNegativo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 2)),
          rutDonante: "33333333-3",
        );

        final solicitud = SolicitudDespacho(
          id: "9000002",
          unidadesSolicitadas: {TipoSangre.abNegativo: 3},
          tipoDespacho: TipoDespacho.urgente,
          stockDisponible: {TipoSangre.abNegativo: 3},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: PantallaGenerarDespacho(
              solicitud: solicitud,
              registroDespacho: registroDespacho,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key("boton_generar_despacho")));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("alerta_falta_stock")), findsOneWidget);
        expect(find.textContaining("No hay stock suficiente"), findsOneWidget);
        expect(find.text("Pendiente"), findsOneWidget);
        expect(solicitud.estadoSolicitud, EstadoSolicitud.pendiente);
      },
    );
  });
}