import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_registro_donaciones.dart";

void main() {
  //late al ser variable que no puede recibir nulos
  late RegistroDonacion registroDonacion;

  setUp(() {
    // se utiliza un id fijo
    registroDonacion = RegistroDonacion(generarId: () => "1234567");
  });

  // se carga la pantalla en un WidgetTester para poder testearla
  Future<void> cargarPantalla(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaRegistroDonaciones(registroDonacion: registroDonacion),
      ),
    );

    await tester.pumpAndSettle();
  }

  //se completan los campos necesarios para registrar una donacion
  Future<void> completarFormulario(WidgetTester tester) async {
    //se encuentra cada widget con la key y se completa

    //rut
    await tester.enterText(
      find.byKey(const Key("campo_rut_donante")),
      "12345678-5",
    );

    //tipo de sangre
    await tester.tap(find.byKey(const Key("dropdown_tipo_sangre")));
    await tester.pumpAndSettle();

    //se selecciona un tipo de sangre
    await tester.tap(find.text(TipoSangre.values.first.etiqueta).last);
    await tester.pumpAndSettle();

    // volumen donado
    await tester.enterText(
      find.byKey(const Key("campo_volumen_donado")),
      "450",
    );

    // fecha de toma
    await tester.tap(find.byKey(const Key("campo_fecha_toma")));
    await tester.pumpAndSettle();

    // se coloca la fecha en el calendario.
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
  }

  group("Tests de PantallaRegistroDonaciones", () {

    // TEST 1
    testWidgets("Registrar donación desde la vista exitosamente", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);

      await completarFormulario(tester);

      //boton registrar
      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );

      // se comprueba que el boton este habilitado
      expect(boton.onPressed, isNotNull);

      //se presiona "registrar donacion"
      await tester.tap(find.byKey(const Key("boton_registrar")));
      await tester.pumpAndSettle();

      // se comprueba que la donacion quedo registrada (dado que la estructura p debe tener 1 donacion)
      expect(registroDonacion.cantidadDonaciones, 1);

      // se comprueba el mensaje de exito
      expect(find.text("Donanción registrada exitosamente"), findsOneWidget);
    });


    // TEST 2
    testWidgets("Validar campos obligatorios vacíos en la vista", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);

      //no completamos el formulario con lo cual queda vacio.

      //el map inicia vacio, sin donaciones
      expect(registroDonacion.cantidadDonaciones, 0);

      //boton registrar
      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );

      //el boton debe estar deshabilitado
      expect(boton.onPressed, isNull);

      //no debe haberse registrado ninguna donacion con lo cual la estructura de donaciones
      //debe seguir vacia
      expect(registroDonacion.cantidadDonaciones, 0);
    });

    // TEST 3
    testWidgets("Validar rango de volumen en la vista", (
      WidgetTester tester,
    ) async {
      await cargarPantalla(tester);

      // se completan los datos con los valores fijos
      await completarFormulario(tester);

      // se modifica el valor del volumen a 0
      await tester.enterText(
        find.byKey(const Key("campo_volumen_donado")),
        "0",
      );

      await tester.pumpAndSettle();


      //boton registrar
      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_registrar")),
      );

      // el boton registrar debe estar desabilitado
      expect(boton.onPressed, isNull);

      // no debe haberse registrado ninguna donacion (estructura vacia)
      expect(registroDonacion.cantidadDonaciones, 0);
    });
  });
}
