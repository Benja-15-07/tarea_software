import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/registro_donantes.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_registro_donaciones.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";

void main() {
  late RegistroDonacion registroDonacion;
  late RegistroDonantes registroDonantes;

  setUp(() {
    registroDonacion = RegistroDonacion(generarId: () => "1234567");
    registroDonantes = RegistroDonantes();

    // Se registra un donante apto para utilizarlo en los tests.
    final donante = Donante(
      rut: "12345678-5",
      nombre: "Juan Perez",
      fechaNacimiento: DateTime(1995, 5, 10),
      tipoSangre: TipoSangre.values.first,
      peso: 70,
      telefono: "912345678",
      elegibilidad: EstadoElegibilidad.apto,
    );
    registroDonantes.ingresarDonante(donante);
  });

  Future<void> cargarPantalla(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaRegistroDonaciones(
          registroDonacion: registroDonacion,
          registroDonantes: registroDonantes,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Se completan los campos necesarios para registrar una donación
  Future<void> completarFormulario(WidgetTester tester) async {
    // Al ingresar el RUT de un donante registrado, el grupo sanguíneo se asigna automáticamente
    await tester.enterText(
      find.byKey(const Key("campo_rut_donante")),
      "12345678-5",
    );
    await tester.pumpAndSettle();

    // Volumen donado
    await tester.enterText(
      find.byKey(const Key("campo_volumen_donado")),
      "450",
    );
    await tester.pumpAndSettle();

    // Fecha de toma
    await tester.tap(find.byKey(const Key("campo_fecha_toma")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
  }

  group("Tests de PantallaRegistroDonaciones", () {
    // TEST 1
    testWidgets("Registrar donación desde la vista exitosamente y mostrar tarjeta del donante", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);
      await completarFormulario(tester);

      // Verifica que se despliegue la tarjeta informativa con nombre y tipo de sangre
      expect(find.byKey(const Key("tarjeta_info_donante")), findsOneWidget);
      expect(find.textContaining("Donante: Juan Perez | Grupo: A+"), findsOneWidget);

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );
      expect(boton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key("boton_registrar")));
      await tester.pumpAndSettle();

      expect(registroDonacion.cantidadDonaciones, 1);
      expect(
        find.text("Donación registrada exitosamente (ID: 1234567)"),
        findsOneWidget,
      );
    });

    // TEST 2
    testWidgets("Validar campos obligatorios vacíos en la vista", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);
      expect(registroDonacion.cantidadDonaciones, 0);

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );
      expect(boton.onPressed, isNull);
      expect(registroDonacion.cantidadDonaciones, 0);
    });

    // TEST 3
    testWidgets("Validar rango de volumen en la vista", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);
      await completarFormulario(tester);

      await tester.enterText(
        find.byKey(const Key("campo_volumen_donado")),
        "0",
      );
      await tester.pumpAndSettle();

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );
      expect(boton.onPressed, isNull);
      expect(registroDonacion.cantidadDonaciones, 0);
    });

    // TEST 4
    testWidgets("Rechazar RUT de donante no registrado", (
      WidgetTester tester,
    ) async {
      registroDonantes = RegistroDonantes();
      await cargarPantalla(tester);

      await tester.enterText(
        find.byKey(const Key("campo_rut_donante")),
        "12345678-5",
      );
      await tester.pumpAndSettle();

      expect(
        find.text("No existe un donante registrado con este RUT."),
        findsOneWidget,
      );

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );
      expect(boton.onPressed, isNull);
      expect(registroDonacion.cantidadDonaciones, 0);
    });

    // TEST 5
    testWidgets("Rechazar donante registrado que no está apto para donar", (
      WidgetTester tester,
    ) async {
      registroDonantes.actualizarElegibilidadDonante(
        "12345678-5",
        EstadoElegibilidad.noAptoTemporalmente,
      );
      await cargarPantalla(tester);

      await tester.enterText(
        find.byKey(const Key("campo_rut_donante")),
        "12345678-5",
      );
      await tester.enterText(
        find.byKey(const Key("campo_volumen_donado")),
        "450",
      );
      await tester.pumpAndSettle();

      expect(
        find.text("El donante no está apto para donar (No apto temporalmente)."),
        findsOneWidget,
      );

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );
      expect(boton.onPressed, isNull);
      expect(registroDonacion.cantidadDonaciones, 0);
    });
  });
}