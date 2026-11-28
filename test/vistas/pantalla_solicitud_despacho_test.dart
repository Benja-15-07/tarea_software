import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_solicitud_despacho.dart";

void main() {
  late RegistroDonacion registroDonacion;
  late RegistroSolicitudDespacho registroSolicitudes;

  setUp(() {
    registroDonacion = RegistroDonacion();
    registroSolicitudes = RegistroSolicitudDespacho(
      registroDonacion: registroDonacion,
      generarId: () => "7654321",
    );
  });

  void agregarDonaciones(TipoSangre tipo, int cantidad) {
    for (int i = 0; i < cantidad; i++) {
      registroDonacion.ingresarDonacion(
        tipoSangre: tipo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now(),
        rutDonante: "12345678-5",
      );
    }
  }

  Future<void> cargarPantalla(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaSolicitudDespacho(
          registroSolicitudDespacho: registroSolicitudes,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> seleccionarUrgencia(
    WidgetTester tester,
    TipoDespacho urgencia,
  ) async {
    await tester.tap(find.byKey(const Key("dropdown_tipo_despacho")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(urgencia.etiqueta).last);
    await tester.pumpAndSettle();
  }

  Future<void> seleccionarTipoYCantidad(
    WidgetTester tester,
    String etiquetaConStock,
    String cantidad,
  ) async {
    await tester.tap(find.byKey(const Key("dropdown_tipo_sangre_solicitud")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(etiquetaConStock).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key("campo_cantidad_solicitud")),
      cantidad,
    );
    await tester.pumpAndSettle();
  }

  group("Tests de PantallaSolicitudDespacho", () {
    testWidgets("Test 1: Ingreso de solicitud exitoso con múltiples tipos de sangre", (
      WidgetTester tester,
    ) async {
      agregarDonaciones(TipoSangre.oPositivo, 3);
      agregarDonaciones(TipoSangre.aNegativo, 2);

      await cargarPantalla(tester);

      // Selecciona urgencia
      await seleccionarUrgencia(tester, TipoDespacho.urgente);

      // Agrega primer tipo de sangre (O+)
      await seleccionarTipoYCantidad(tester, "O+ (Disp: 3)", "2");
      await tester.tap(find.byKey(const Key("boton_agregar_tipo")));
      await tester.pumpAndSettle();

      // Agrega segundo tipo de sangre (A-)
      await seleccionarTipoYCantidad(tester, "A- (Disp: 2)", "1");
      await tester.tap(find.byKey(const Key("boton_agregar_tipo")));
      await tester.pumpAndSettle();

      // Verifica que el botón enviar está habilitado y envía la solicitud
      final botonEnviar = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_enviar_solicitud")),
      );
      expect(botonEnviar.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key("boton_enviar_solicitud")));
      await tester.pumpAndSettle();

      expect(registroSolicitudes.cantidadSolicitudes, 1);
      expect(
        find.text("Solicitud registrada exitosamente (ID: 7654321)"),
        findsOneWidget,
      );
    });

    testWidgets("Test 2: No permite ingresar solicitud si faltan campos obligatorios", (
      WidgetTester tester,
    ) async {
      agregarDonaciones(TipoSangre.oPositivo, 2);

      await cargarPantalla(tester);

      // Sin urgencia ni tipos agregados
      var botonEnviar = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_enviar_solicitud")),
      );
      expect(botonEnviar.onPressed, isNull);

      // Solo urgencia, sin tipos agregados
      await seleccionarUrgencia(tester, TipoDespacho.normal);
      botonEnviar = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_enviar_solicitud")),
      );
      expect(botonEnviar.onPressed, isNull);
      expect(registroSolicitudes.cantidadSolicitudes, 0);
    });

    testWidgets("Test 3: Rechaza cantidad que excede el stock disponible", (
      WidgetTester tester,
    ) async {
      agregarDonaciones(TipoSangre.oPositivo, 2);

      await cargarPantalla(tester);
      await seleccionarUrgencia(tester, TipoDespacho.urgente);

      // Intenta solicitar 5 unidades cuando solo hay 2
      await seleccionarTipoYCantidad(tester, "O+ (Disp: 2)", "5");

      expect(find.text("Stock insuficiente (disponible: 2)."), findsOneWidget);

      final botonAgregar = tester.widget<OutlinedButton>(
        find.byKey(const Key("boton_agregar_tipo")),
      );
      expect(botonAgregar.onPressed, isNull);

      final botonEnviar = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_enviar_solicitud")),
      );
      expect(botonEnviar.onPressed, isNull);
      expect(registroSolicitudes.cantidadSolicitudes, 0);
    });

    testWidgets("Muestra alerta y deshabilita envío cuando no hay donaciones en inventario", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);

      expect(find.byKey(const Key("alerta_sin_donaciones")), findsOneWidget);

      final botonEnviar = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_enviar_solicitud")),
      );
      expect(botonEnviar.onPressed, isNull);
    });

    testWidgets("Impide agregar el mismo tipo de sangre dos veces", (
      WidgetTester tester,
    ) async {
      agregarDonaciones(TipoSangre.aPositivo, 4);

      await cargarPantalla(tester);
      await seleccionarTipoYCantidad(tester, "A+ (Disp: 4)", "1");
      await tester.tap(find.byKey(const Key("boton_agregar_tipo")));
      await tester.pumpAndSettle();

      // Abre nuevamente el dropdown y verifica que A+ ya no está disponible para volver a añadirse
      await tester.tap(find.byKey(const Key("dropdown_tipo_sangre_solicitud")));
      await tester.pumpAndSettle();
      expect(find.text("A+ (Disp: 4)"), findsNothing);
    });
  });
}