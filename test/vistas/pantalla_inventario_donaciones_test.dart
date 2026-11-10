import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    testWidgets('Mostrar mensaje de inventario vacío cuando no hay unidades', (WidgetTester tester) async {
      // Cargar la pantalla con el registro vacío
      await tester.pumpWidget(crearPantallaPrueba(registro));
      await tester.pumpAndSettle();

      // Verificar que se muestre el texto de inventario vacío
      expect(find.text('No hay unidades disponibles'), findsOneWidget);
      expect(
        find.text('Actualmente el sistema no registra unidades de sangre disponibles en el inventario.'),
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

    });
  });
  
}