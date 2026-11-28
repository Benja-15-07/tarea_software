import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/rol.dart";
import "package:proyecto_banco_sangre/logica/registro_usuarios.dart";
import "package:proyecto_banco_sangre/logica/usuario.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";
import "package:proyecto_banco_sangre/vistas/pantalla_inicio_sesion.dart";

void main() {
  late RegistroUsuarios registro;

  setUp(() {
    registro = RegistroUsuarios();
    registro.ingresarUsuario(
      Usuario(
        usuario: "juan",
        contrasena: "secreto123",
        rol: Rol.gestorInventario,
      ),
    );
  });

  Future<void> cargarPantalla(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaInicioSesion(registroUsuarios: registro),
      ),
    );
    await tester.pumpAndSettle();
  }

  group("PantallaInicioSesion", () {
    testWidgets("Test 1: muestra campos de usuario, contraseña y botón", (
      tester,
    ) async {
      await cargarPantalla(tester);

      expect(find.byKey(const Key("campo_usuario")), findsOneWidget);
      expect(find.byKey(const Key("campo_contrasena")), findsOneWidget);
      expect(find.byKey(const Key("boton_iniciar_sesion")), findsOneWidget);

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_iniciar_sesion")),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets("Test 2: valida campos obligatorios vacíos", (tester) async {
      await cargarPantalla(tester);

      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_iniciar_sesion")),
      );
      expect(boton.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key("campo_usuario")),
        "juan",
      );
      await tester.pump();

      // Falta contraseña, el botón sigue deshabilitado
      final botonTrasUsuario = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_iniciar_sesion")),
      );
      expect(botonTrasUsuario.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key("campo_contrasena")),
        "secreto123",
      );
      await tester.pump();

      final botonCompleto = tester.widget<ElevatedButton>(
        find.byKey(const Key("boton_iniciar_sesion")),
      );
      expect(botonCompleto.onPressed, isNotNull);
    });

    testWidgets("Test 3: muestra error con credenciales inválidas", (
      tester,
    ) async {
      await cargarPantalla(tester);

      await tester.enterText(
        find.byKey(const Key("campo_usuario")),
        "juan",
      );
      await tester.enterText(
        find.byKey(const Key("campo_contrasena")),
        "incorrecta",
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key("boton_iniciar_sesion")));
      await tester.pumpAndSettle();

      expect(
        find.text("Credenciales inválidas. Verifique su usuario y contraseña."),
        findsOneWidget,
      );
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, ColoresApp.error);
    });

    testWidgets("Inicio de sesión exitoso muestra mensaje con el rol", (
      tester,
    ) async {
      await cargarPantalla(tester);

      await tester.enterText(
        find.byKey(const Key("campo_usuario")),
        "juan",
      );
      await tester.enterText(
        find.byKey(const Key("campo_contrasena")),
        "secreto123",
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key("boton_iniciar_sesion")));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Inicio de sesión exitoso"),
        findsOneWidget,
      );
      expect(
        find.textContaining("Gestor de Inventario"),
        findsOneWidget,
      );
    });
  });
}