import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_historial_donaciones.dart";

void main() {
  RegistroDonacion crearRegistroVariado() {
    int idActual = 1000000;
    final registro = RegistroDonacion(
      generarId: () => (idActual++).toString(),
    );

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // 1. Disponible
    registro.ingresarDonacion(
      tipoSangre: TipoSangre.oPositivo,
      volumenDonado: 450,
      fechaDeToma: hoy,
      rutDonante: "12345678-5",
    );

    // 2. Despachada
    final idDespachada = registro.ingresarDonacion(
      tipoSangre: TipoSangre.aNegativo,
      volumenDonado: 420,
      fechaDeToma: hoy.subtract(const Duration(days: 3)),
      rutDonante: "11111111-1",
    );
    registro.actualizarEstadoDonacion(idDespachada, EstadoDonacion.despachada);

    // 3. Desechada
    final idDesechada = registro.ingresarDonacion(
      tipoSangre: TipoSangre.bPositivo,
      volumenDonado: 480,
      fechaDeToma: hoy.subtract(const Duration(days: 7)),
      rutDonante: "22222222-2",
    );
    registro.actualizarEstadoDonacion(idDesechada, EstadoDonacion.desechada);

    return registro;
  }

  Future<void> montarVista(
    WidgetTester tester,
    RegistroDonacion registro,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaHistorialDonaciones(registroDonacion: registro),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    "Despliega todas las filas históricas con id, tipo de sangre, volumen, estado y fecha de actualización",
    (tester) async {
      final registro = crearRegistroVariado();
      await montarVista(tester, registro);

      expect(find.byKey(const Key("lista_historial_donaciones")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_1000000")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_1000001")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_1000002")), findsOneWidget);

      // Datos de cada donación
      expect(find.textContaining("1000000"), findsOneWidget);
      expect(find.textContaining("450 ml"), findsOneWidget);
      expect(find.textContaining("Disponible"), findsOneWidget);

      expect(find.textContaining("1000001"), findsOneWidget);
      expect(find.textContaining("420 ml"), findsOneWidget);
      expect(find.textContaining("Despachada"), findsOneWidget);

      expect(find.textContaining("1000002"), findsOneWidget);
      expect(find.textContaining("480 ml"), findsOneWidget);
      expect(find.textContaining("Desechada"), findsOneWidget);

      // Etiqueta de fecha de actualización en todas las filas
      expect(find.textContaining("Actualización:"), findsNWidgets(3));
    },
  );

  testWidgets(
    "Muestra mensaje de estado vacío cuando no hay donaciones registradas",
    (tester) async {
      final registroVacio = RegistroDonacion();
      await montarVista(tester, registroVacio);

      expect(find.byKey(const Key("mensaje_historial_vacio")), findsOneWidget);
      expect(
        find.text("Aún no hay donaciones registradas en el historial."),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key("lista_historial_donaciones")),
        findsNothing,
      );
    },
  );

  testWidgets(
    "Refleja en el historial una donación que pasa a despachada al actualizar",
    (tester) async {
      int idActual = 3000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.abPositivo,
        volumenDonado: 450,
        fechaDeToma: hoy,
        rutDonante: "12345678-5",
      );

      await montarVista(tester, registro);
      expect(find.textContaining("Disponible"), findsOneWidget);

      registro.actualizarEstadoDonacion(id, EstadoDonacion.despachada);
      await tester.tap(find.byKey(const Key("boton_actualizar_historial")));
      await tester.pumpAndSettle();

      expect(find.textContaining("Despachada"), findsOneWidget);
      expect(find.textContaining("Actualización:"), findsOneWidget);
    },
  );

  testWidgets(
    "Refleja en el historial una donación que pasa a desechada al actualizar",
    (tester) async {
      int idActual = 4000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.oNegativo,
        volumenDonado: 400,
        fechaDeToma: hoy,
        rutDonante: "9876543-2",
      );

      await montarVista(tester, registro);
      expect(find.textContaining("Disponible"), findsOneWidget);

      registro.actualizarEstadoDonacion(id, EstadoDonacion.desechada);
      await tester.tap(find.byKey(const Key("boton_actualizar_historial")));
      await tester.pumpAndSettle();

      expect(find.textContaining("Desechada"), findsOneWidget);
      expect(find.textContaining("Actualización:"), findsOneWidget);
    },
  );

  testWidgets(
    "Transita de estado vacío a listado cuando se ingresan donaciones y se actualiza",
    (tester) async {
      int idActual = 5000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      await montarVista(tester, registro);
      expect(find.byKey(const Key("mensaje_historial_vacio")), findsOneWidget);

      registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: hoy,
        rutDonante: "1357924-6",
      );

      await tester.tap(find.byKey(const Key("boton_actualizar_historial")));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("mensaje_historial_vacio")), findsNothing);
      expect(find.byKey(const Key("lista_historial_donaciones")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_5000000")), findsOneWidget);
    },
  );

  testWidgets(
    "Conserva y muestra múltiples unidades (incluyendo mismo tipo de sangre)",
    (tester) async {
      int idActual = 6000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      for (int i = 0; i < 4; i++) {
        registro.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy,
          rutDonante: "12345678-5",
        );
      }

      await montarVista(tester, registro);

      expect(find.byKey(const Key("fila_donacion_6000000")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_6000001")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_6000002")), findsOneWidget);
      expect(find.byKey(const Key("fila_donacion_6000003")), findsOneWidget);
      expect(find.textContaining("Actualización:"), findsNWidgets(4));
    },
  );

  testWidgets(
    "Abre el diálogo de detalle al tocar una fila del historial",
    (tester) async {
      final registro = crearRegistroVariado();
      await montarVista(tester, registro);

      await tester.tap(find.byKey(const Key("fila_donacion_1000000")));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Detalle de donación"), findsOneWidget);
      expect(find.text("1000000"), findsOneWidget);
      expect(find.text("12345678-5"), findsOneWidget);
      expect(find.text("450 ml"), findsOneWidget);
      expect(find.text("Fecha de toma:"), findsOneWidget);
      expect(find.text("Fecha de caducidad:"), findsOneWidget);
      expect(find.text("Estado:"), findsOneWidget);
    },
  );

  testWidgets(
    "Ordena el historial de forma descendente por fechaActualizacionEstado",
    (tester) async {
      int idActual = 7000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      // 7000000: registrada hace 2 horas
      final idAnterior = registro.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: hoy,
        rutDonante: "12345678-5",
      );
      registro.buscarPorId(idAnterior)!.fechaActualizacionEstado =
          ahora.subtract(const Duration(hours: 2));
          
      // 7000001: toma antigua, pero actualizada ahora (más reciente)
      final idReciente = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aNegativo,
        volumenDonado: 450,
        fechaDeToma: hoy.subtract(const Duration(days: 10)),
        rutDonante: "11111111-1",
      );
      registro.actualizarEstadoDonacion(idReciente, EstadoDonacion.despachada);
      await montarVista(tester, registro);
      final yReciente = tester.getTopLeft(
        find.byKey(const Key("fila_donacion_7000001")),
      ).dy;
      final yAnterior = tester.getTopLeft(
        find.byKey(const Key("fila_donacion_7000000")),
      ).dy;
      
      expect(yReciente, lessThan(yAnterior));
    },
  );
  testWidgets(
    "Muestra estado Vencida en el historial para una donación disponible expirada",
    (tester) async {
      int idActual = 8000000;
      final registro = RegistroDonacion(
        generarId: () => (idActual++).toString(),
      );
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      registro.ingresarDonacion(
        tipoSangre: TipoSangre.abPositivo,
        volumenDonado: 450,
        fechaDeToma: hoy.subtract(const Duration(days: 50)),
        rutDonante: "16789432-1",
      );
      await montarVista(tester, registro);
      expect(find.text("Vencida"), findsOneWidget);
      expect(find.text("Disponible"), findsNothing);
    },
  );
}