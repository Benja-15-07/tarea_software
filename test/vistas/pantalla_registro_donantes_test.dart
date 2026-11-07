import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donantes.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_registro_donantes.dart";

void main() {
  late RegistroDonantes registroDonantes;

  // Helper para envolver el widget en MaterialApp y con suficiente alto de pantalla
  Future<void> cargarPantalla(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaRegistroDonantes(registroDonantes: registroDonantes),
      ),
    );
  }

  // Helper para llenar todos los campos con datos válidos
  Future<void> llenarFormularioValido(
    WidgetTester tester, {
    String rut = "12345678-5",
    String nombre = "Juan Pérez",
    String peso = "75",
    String telefono = "+56912345678",
    String tipoSangreEtiqueta = "O+",
    String elegibilidadEtiqueta = "Apto",
  }) async {
    await tester.enterText(find.byKey(const Key("campo_rut")), rut);
    await tester.enterText(find.byKey(const Key("campo_nombre")), nombre);

    // Seleccionar Fecha en DatePicker (por defecto se abre hace 25 años, que es válida)
    await tester.tap(find.byKey(const Key("campo_fecha")));
    await tester.pumpAndSettle();
    // Presionar el botón de confirmar en el DatePicker (OK / Aceptar)
    final botonConfirmar = find.text("OK").evaluate().isNotEmpty
        ? find.text("OK")
        : find.text("ACEPTAR");
    await tester.tap(botonConfirmar);
    await tester.pumpAndSettle();

    // Seleccionar Tipo de Sangre
    await tester.tap(find.byKey(const Key("dropdown_tipo_sangre")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tipoSangreEtiqueta).last);
    await tester.pumpAndSettle();

    // Ingresar Peso
    await tester.enterText(find.byKey(const Key("campo_peso")), peso);

    // Ingresar Teléfono
    await tester.enterText(find.byKey(const Key("campo_telefono")), telefono);

    // Seleccionar Estado de Elegibilidad
    await tester.tap(find.byKey(const Key("dropdown_elegibilidad")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(elegibilidadEtiqueta).last);
    await tester.pumpAndSettle();
  }

  setUp(() {
    registroDonantes = RegistroDonantes();
  });
  group("Renderizado y estado inicial", () {
    testWidgets("Muestra todos los campos, textos principales y el botón deshabilitado al iniciar", (tester) async {
      await cargarPantalla(tester);

      expect(find.text("Sistema de Gestión de Sangre"), findsOneWidget);
      expect(find.text("Registro de Nuevo Donante"), findsOneWidget);

      expect(find.byKey(const Key("campo_rut")), findsOneWidget);
      expect(find.byKey(const Key("campo_nombre")), findsOneWidget);
      expect(find.byKey(const Key("campo_fecha")), findsOneWidget);
      expect(find.byKey(const Key("dropdown_tipo_sangre")), findsOneWidget);
      expect(find.byKey(const Key("campo_peso")), findsOneWidget);
      expect(find.byKey(const Key("campo_telefono")), findsOneWidget);
      expect(find.byKey(const Key("dropdown_elegibilidad")), findsOneWidget);
      expect(find.byKey(const Key("boton_registrar")), findsOneWidget);

      final boton = tester.widget<ElevatedButton>(find.byKey(const Key("boton_registrar")));
      expect(boton.onPressed, isNull);
    });
  });
  group("Validaciones interactivas de campos", () {
    testWidgets("Valida correctamente errores en el campo RUT", (tester) async {
      await cargarPantalla(tester);
      final campoRut = find.byKey(const Key("campo_rut"));

      // Ingresar RUT inválido
      await tester.enterText(campoRut, "12345678-9");
      await tester.pump();
      expect(
        find.textContaining("El RUT ingresado no tiene un formato válido"),
        findsOneWidget,
      );

      // Dejar RUT vacío tras interactuar
      await tester.enterText(campoRut, "");
      await tester.pump();
      expect(find.text("El RUT no puede estar vacío."), findsOneWidget);

      // Ingresar RUT válido desaparece el error
      await tester.enterText(campoRut, "12345678-5");
      await tester.pump();
      expect(find.text("El RUT no puede estar vacío."), findsNothing);
    });

    testWidgets("Valida correctamente que el nombre no esté vacío", (tester) async {
      await cargarPantalla(tester);
      final campoNombre = find.byKey(const Key("campo_nombre"));

      await tester.enterText(campoNombre, "   ");
      await tester.pump();
      expect(find.text("El nombre no puede estar vacío."), findsOneWidget);

      await tester.enterText(campoNombre, "María Soto");
      await tester.pump();
      expect(find.text("El nombre no puede estar vacío."), findsNothing);
    });

    testWidgets("Valida formato numérico, rango y comas decimales en el campo Peso", (tester) async {
      await cargarPantalla(tester);
      final campoPeso = find.byKey(const Key("campo_peso"));

      // No numérico
      await tester.enterText(campoPeso, "abc");
      await tester.pump();
      expect(find.text("Ingrese un valor numérico válido (ej: 70.5)."), findsOneWidget);

      // Vacío
      await tester.enterText(campoPeso, "");
      await tester.pump();
      expect(find.text("El peso no puede estar vacío."), findsOneWidget);

      // Fuera de rango (<= 0 o > 300)
      await tester.enterText(campoPeso, "-5");
      await tester.pump();
      expect(find.text("Ingrese un peso válido mayor a 0 kg."), findsOneWidget);

      // Peso válido con coma decimal
      await tester.enterText(campoPeso, "70,5");
      await tester.pump();
      expect(find.text("Ingrese un valor numérico válido (ej: 70.5)."), findsNothing);
      expect(find.text("Ingrese un peso válido mayor a 0 kg."), findsNothing);
    });

    testWidgets("Valida correctamente el formato del campo Teléfono", (tester) async {
      await cargarPantalla(tester);
      final campoTelefono = find.byKey(const Key("campo_telefono"));

      await tester.enterText(campoTelefono, "12345");
      await tester.pump();
      expect(
        find.textContaining("El teléfono ingresado no tiene un formato válido"),
        findsOneWidget,
      );

      await tester.enterText(campoTelefono, "912345678");
      await tester.pump();
      expect(
        find.textContaining("El teléfono ingresado no tiene un formato válido"),
        findsNothing,
      );
    });
  });

  group("Selector de fecha y Dropdowns", () {
    testWidgets("Abre el DatePicker al tocar el campo fecha y formatea la selección dd/mm/yyyy", (tester) async {
      await cargarPantalla(tester);

      await tester.tap(find.byKey(const Key("campo_fecha")));
      await tester.pumpAndSettle();

      expect(find.text("Seleccione fecha de nacimiento"), findsOneWidget);

      final botonConfirmar = find.text("OK").evaluate().isNotEmpty
          ? find.text("OK")
          : find.text("ACEPTAR");
      await tester.tap(botonConfirmar);
      await tester.pumpAndSettle();

      final hoy = DateTime.now();
      final anioEsperado = (hoy.year - 25).toString();
      final campoFechaWidget = tester.widget<TextFormField>(find.byKey(const Key("campo_fecha")));
      expect(campoFechaWidget.controller!.text, contains(anioEsperado));
    });

    testWidgets("Permite seleccionar opciones en los Dropdowns de grupo sanguíneo y elegibilidad", (tester) async {
      await cargarPantalla(tester);

      await tester.tap(find.byKey(const Key("dropdown_tipo_sangre")));
      await tester.pumpAndSettle();
      await tester.tap(find.text("AB-").last);
      await tester.pumpAndSettle();
      expect(find.text("AB-"), findsOneWidget);

      await tester.tap(find.byKey(const Key("dropdown_elegibilidad")));
      await tester.pumpAndSettle();
      await tester.tap(find.text("No apto temporalmente").last);
      await tester.pumpAndSettle();
      expect(find.text("No apto temporalmente"), findsOneWidget);
    });
  });

  group("Reactividad del botón Registrar Donante", () {
    testWidgets("Se habilita al completar todo válidamente y se deshabilita si un campo pasa a ser inválido", (tester) async {
      await cargarPantalla(tester);

      await llenarFormularioValido(tester);

      // Con todos los campos válidos, el botón debe estar habilitado
      ElevatedButton boton = tester.widget<ElevatedButton>(find.byKey(const Key("boton_registrar")));
      expect(boton.onPressed, isNotNull);

      // Si el usuario corrompe el RUT, el botón se deshabilita en tiempo real
      await tester.enterText(find.byKey(const Key("campo_rut")), "rut-invalido");
      await tester.pump();

      boton = tester.widget<ElevatedButton>(find.byKey(const Key("boton_registrar")));
      expect(boton.onPressed, isNull);
    });
  });

  group("Registro exitoso y limpieza de formulario", () {
    testWidgets("Guarda el donante, muestra SnackBar de éxito y limpia todos los campos", (tester) async {
      await cargarPantalla(tester);

      await llenarFormularioValido(
        tester,
        rut: "16378047-k",
        nombre: "Ana Silva",
        peso: "65,5",
        telefono: "987654321",
        tipoSangreEtiqueta: "A+",
        elegibilidadEtiqueta: "Apto",
      );

      await tester.tap(find.byKey(const Key("boton_registrar")));
      await tester.pump();

      //Verifica que se haya guardado en RegistroDonantes
      expect(registroDonantes.cantidadDonantes, 1);
      final donanteGuardado = registroDonantes.buscarPorRut("16378047-K");
      expect(donanteGuardado, isNotNull);
      expect(donanteGuardado!.nombre, "Ana Silva");
      expect(donanteGuardado.peso, 65.5);
      expect(donanteGuardado.tipoSangre, TipoSangre.aPositivo);
      expect(donanteGuardado.elegibilidad, EstadoElegibilidad.apto);

      //Verifica SnackBar de éxito
      expect(find.text("Donante registrado exitosamente."), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, ColoresApp.exito);

      //Verifica que los campos se hayan limpiado y el botón esté deshabilitado
      final rutField = tester.widget<TextFormField>(find.byKey(const Key("campo_rut")));
      final nombreField = tester.widget<TextFormField>(find.byKey(const Key("campo_nombre")));
      final fechaField = tester.widget<TextFormField>(find.byKey(const Key("campo_fecha")));
      final pesoField = tester.widget<TextFormField>(find.byKey(const Key("campo_peso")));
      final telefonoField = tester.widget<TextFormField>(find.byKey(const Key("campo_telefono")));

      expect(rutField.controller!.text, isEmpty);
      expect(nombreField.controller!.text, isEmpty);
      expect(fechaField.controller!.text, isEmpty);
      expect(pesoField.controller!.text, isEmpty);
      expect(telefonoField.controller!.text, isEmpty);

      final boton = tester.widget<ElevatedButton>(find.byKey(const Key("boton_registrar")));
      expect(boton.onPressed, isNull);
    });
  });

  group("Manejo de RUT duplicado", () {
    testWidgets("Muestra SnackBar de error y mantiene los datos en el formulario si el RUT ya existe", (tester) async {
      // Pre-cargamos un donante con el RUT 12345678-5
      registroDonantes.ingresarDonante(
        Donante(
          rut: "12345678-5",
          nombre: "Donante Existente",
          fechaNacimiento: DateTime(1995, 5, 20),
          tipoSangre: TipoSangre.oNegativo,
          peso: 80,
          telefono: "+56911111111",
          elegibilidad: EstadoElegibilidad.apto,
        ),
      );

      await cargarPantalla(tester);

      // Intentamos registrar otro donante con el mismo RUT
      await llenarFormularioValido(
        tester,
        rut: "12345678-5",
        nombre: "Intento Duplicado",
        peso: "70",
        telefono: "+56922222222",
      );

      await tester.tap(find.byKey(const Key("boton_registrar")));
      await tester.pump();

      //La cantidad no aumenta y se conserva el donante original
      expect(registroDonantes.cantidadDonantes, 1);
      expect(registroDonantes.buscarPorRut("12345678-5")!.nombre, "Donante Existente");

      //Se muestra el SnackBar de error con el color correspondiente
      expect(
        find.text("Error: Ya existe un donante registrado con ese RUT."),
        findsOneWidget,
      );
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, ColoresApp.error);

      //El formulario NO se limpia para permitir corregir el RUT
      final nombreField = tester.widget<TextFormField>(find.byKey(const Key("campo_nombre")));
      expect(nombreField.controller!.text, "Intento Duplicado");
    });
  });
}