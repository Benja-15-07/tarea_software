import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inventario_donaciones.dart';

void main() {
  late RegistroDonacion registro;

  setUp(() {
    registro = RegistroDonacion();
  });

  // Función auxiliar para renderizar la pantalla en el entorno de pruebas
  Widget crearPantallaPrueba(RegistroDonacion reg) {
    return MaterialApp(
      home: PantallaInventarioDonaciones(registroDonacion: reg),
    );
  }

  group('Pruebas de vista para PantallaInventarioDonaciones', () {
    testWidgets('Mostrar mensaje de inventario vacío cuando no hay unidades', (
      WidgetTester tester,
    ) async {
      // Cargar la pantalla con el registro vacío
      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();

      // Verificar que se muestre el texto de inventario vacío
      expect(find.text('No hay unidades disponibles'), findsOneWidget);
      expect(
        find.text(
          'Actualmente el sistema no registra unidades de sangre disponibles en el inventario.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Visualizar inventario y grupos sanguíneos cuando existen unidades',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        // Donación de prueba
        final id = registro.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: DateTime.now().subtract(const Duration(days: 1)),
          rutDonante: "12345678-5",
        );

        // Cargar la pantalla con datos y renderizar
        await tester.pumpWidget(crearPantallaPrueba(registro));
        await tester.pumpAndSettle();

        expect(find.text('Grupo Sanguíneo: O+'), findsOneWidget);
        expect(find.text('Disponibles: 1 unidades'), findsOneWidget);
        expect(find.text('No hay unidades disponibles'), findsNothing);

        await tester.tap(find.text('Grupo Sanguíneo: O+'));
        await tester.pumpAndSettle();

        expect(find.textContaining('ID: $id'), findsOneWidget);
        expect(find.textContaining('Volumen: 450 ml'), findsOneWidget);
        expect(find.text('DISPONIBLE'), findsOneWidget);
      },
    );

    testWidgets("Muestra todos los datos de una donación vigente", (
      tester,
    ) async {
      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now(),
        rutDonante: "12345678-9",
      );

      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Grupo Sanguíneo: A+"));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining("ID: $id"));
      await tester.pumpAndSettle();

      expect(find.text("Detalle de donación"), findsOneWidget);
      expect(find.text(id), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text("A+"),
        ),
        findsOneWidget,
      );
      expect(find.text("450 ml"), findsOneWidget);
      expect(find.text("Fecha de toma:"), findsOneWidget);
      expect(find.text("Fecha de caducidad:"), findsOneWidget);
      expect(find.text("Estado:"), findsOneWidget);
      expect(find.text("disponible"), findsOneWidget);
      expect(find.text("Vencida"), findsNothing);
    });

    testWidgets("Muestra advertencia al abrir una donación vencida", (
      tester,
    ) async {
      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now().subtract(const Duration(days: 60)),
        rutDonante: "12345678-9",
      );

      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Grupo Sanguíneo: A+"));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining("ID: $id"));
      await tester.pumpAndSettle();

      expect(find.text("Detalle de donación"), findsOneWidget);
      expect(find.text(id), findsOneWidget);
      expect(find.text("450 ml"), findsOneWidget);
      expect(find.text("Estado:"), findsOneWidget);
      expect(find.text("Vencida"), findsNWidgets(2));
    });

    testWidgets("No abre el detalle de una donación desechada", (tester) async {
      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now(),
        rutDonante: "12345678-9",
      );

      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Grupo Sanguíneo: A+"));
      await tester.pumpAndSettle();

      registro.actualizarEstadoDonacion(id, EstadoDonacion.desechada);

      await tester.tap(find.textContaining("ID: $id"));
      await tester.pumpAndSettle();

      expect(find.text("Detalle de donación"), findsNothing);
      expect(
        find.text("La donación seleccionada no se encuentra disponible"),
        findsOneWidget,
      );
    });

    testWidgets("retira una donación vencida y la quita de la vista", (
      tester,
    ) async {
      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now().subtract(const Duration(days: 60)),
        rutDonante: "12345678-9",
      );

      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Grupo Sanguíneo: A+"));
      await tester.pumpAndSettle();

      final boton = find.byKey(Key("boton_desechar_$id"));
      expect(boton, findsOneWidget);

      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(find.textContaining("ID: $id"), findsNothing);
      expect(find.text("Donación desechada exitosamente"), findsOneWidget);
      expect(
        registro.buscarPorId(id)?.estadoDonacion,
        EstadoDonacion.desechada,
      );
    });

    testWidgets("el botón Desechar está deshabilitado si la donación no está vencida",
      (tester) async {
        final id = registro.ingresarDonacion(
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 450,
          fechaDeToma: DateTime.now(),
          rutDonante: "12345678-9",
        );

        await tester.pumpWidget(crearPantallaPrueba(registro));
        await tester.pumpAndSettle();
        await tester.tap(find.text("Grupo Sanguíneo: A+"));
        await tester.pumpAndSettle();

        final boton = tester.widget<ElevatedButton>(
          find.byKey(Key("boton_desechar_$id")),
        );
        expect(boton.onPressed, isNull);
      },
    );

    testWidgets("el botón Desechar se bloquea mientras hay un retiro en curso",
      (tester) async {
        final id = registro.ingresarDonacion(
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 450,
          fechaDeToma: DateTime.now().subtract(const Duration(days: 60)),
          rutDonante: "12345678-9",
        );

        await tester.pumpWidget(crearPantallaPrueba(registro));
        await tester.pumpAndSettle();
        await tester.tap(find.text("Grupo Sanguíneo: A+"));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("boton_desechar_$id")));
        await tester.pump(); // un frame: operación en curso

        final botonEnCurso = tester.widget<ElevatedButton>(
          find.byKey(Key("boton_desechar_$id")),
        );
        expect(botonEnCurso.onPressed, isNull);

        await tester.pumpAndSettle();
        expect(find.textContaining("ID: $id"), findsNothing);
      },
    );
  });
}
