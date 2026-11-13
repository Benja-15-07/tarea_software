import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_principal.dart';

void main() {
  late RegistroDonantes registroDonantes;
  late RegistroDonacion registroDonacion;

  setUp(() {
    registroDonantes = RegistroDonantes();
    registroDonacion = RegistroDonacion();
  });

  Widget crearApp() {
    return MaterialApp(
      home: PantallaPrincipal(
        registroDonantes: registroDonantes,
        registroDonacion: registroDonacion,
      ),
    );
  }

  group('Pruebas de navegación en PantallaPrincipal', () {
    testWidgets('Inicia en Registro de Donantes y navega por las pestañas', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      // 1. Verifica que inicia en la vista de Donantes
      expect(find.text('Registro de Nuevo Donante'), findsOneWidget);

      // 2. Toca la pestaña 'Donaciones'
      await tester.tap(find.text('Donaciones'));
      await tester.pumpAndSettle();
      expect(find.text('Registro de Nueva Donación'), findsOneWidget);

      // 3. Toca la pestaña 'Inventario'
      await tester.tap(find.text('Inventario'));
      await tester.pumpAndSettle();
      expect(find.text('Inventario de Banco de Sangre'), findsOneWidget);
      expect(find.text('No hay unidades disponibles'), findsOneWidget);
    });

   testWidgets('Refleja en el inventario las donaciones registradas', (
      WidgetTester tester,
    ) async {
      // Ampliar el alto de la pantalla de prueba para que se rendericen todos los grupos sanguíneos
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      registroDonacion.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now(),
        rutDonante: '12345678-5',
      );

      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      // Navegar a Inventario y comprobar que muestra el stock actualizado
      await tester.tap(find.text('Inventario'));
      await tester.pumpAndSettle();

      expect(find.text('Grupo Sanguíneo: O+'), findsOneWidget);
      expect(find.text('Disponibles: 1 unidades'), findsOneWidget);
    });
  });
}