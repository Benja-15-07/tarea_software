import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/enums/rol.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';
import 'package:proyecto_banco_sangre/logica/registro_usuarios.dart';
import 'package:proyecto_banco_sangre/logica/usuario.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_generar_despacho.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_historial_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inicio_sesion.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_inventario_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_principal.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donaciones.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_registro_donantes.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_solicitud_despacho.dart';

void main() {
  late RegistroDonantes registroDonantes;
  late RegistroDonacion registroDonacion;
  late RegistroUsuarios registroUsuarios;

  setUp(() {
    registroDonantes = RegistroDonantes();
    registroDonacion = RegistroDonacion();
    registroUsuarios = RegistroUsuarios();

    registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "receptor",
        contrasena: "clave",
        rol: Rol.receptorDonaciones,
      ),
    );
    registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "gestor",
        contrasena: "clave",
        rol: Rol.gestorInventario,
      ),
    );
    registroUsuarios.ingresarUsuario(
      Usuario(
        usuario: "hospital",
        contrasena: "clave",
        rol: Rol.funcionarioHospital,
      ),
    );
  });

  Widget crearApp() {
    return MaterialApp(
      home: PantallaPrincipal(
        registroDonantes: registroDonantes,
        registroDonacion: registroDonacion,
        registroUsuarios: registroUsuarios,
      ),
    );
  }

  Future<void> iniciarSesion(WidgetTester tester, String usuario) async {
    await tester.enterText(find.byKey(const Key("campo_usuario")), usuario);
    await tester.enterText(find.byKey(const Key("campo_contrasena")), "clave");
    await tester.pump();
    await tester.tap(find.byKey(const Key("boton_iniciar_sesion")));
    await tester.pumpAndSettle();
  }

  group("PantallaPrincipal - login y redirección por rol", () {
    testWidgets("Arranca en la pantalla de inicio de sesión", (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      expect(find.byType(PantallaInicioSesion), findsOneWidget);
      expect(find.byKey(const Key("barra_navegacion_principal")), findsNothing);
      expect(find.byKey(const Key("boton_cerrar_sesion")), findsNothing);
    });

    testWidgets("Receptor de Donaciones ve Donantes y Donaciones", (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      await iniciarSesion(tester, "receptor");

      expect(find.byKey(const Key("barra_navegacion_principal")), findsOneWidget);
      expect(find.text("Donantes"), findsOneWidget);
      expect(find.text("Donaciones"), findsOneWidget);
      expect(find.byType(PantallaRegistroDonantes), findsOneWidget);
      expect(find.byKey(const Key("boton_cerrar_sesion")), findsOneWidget);

      await tester.tap(find.text("Donaciones"));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaRegistroDonaciones), findsOneWidget);
    });

    testWidgets("Gestor de Inventario ve Inventario, Historial y Despachar", (
      tester,
    ) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      await iniciarSesion(tester, "gestor");

      expect(find.byKey(const Key("barra_navegacion_principal")), findsOneWidget);
      expect(find.text("Inventario"), findsOneWidget);
      expect(find.text("Historial"), findsOneWidget);
      expect(find.text("Despachar"), findsOneWidget);
      expect(find.byType(PantallaInventarioDonaciones), findsOneWidget);

      await tester.tap(find.text("Historial"));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaHistorialDonaciones), findsOneWidget);

      await tester.tap(find.text("Despachar"));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaGenerarDespacho), findsOneWidget);
    });

    testWidgets("Funcionario de Hospital solo ve Solicitar (sin barra)", (
      tester,
    ) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      await iniciarSesion(tester, "hospital");

      expect(find.byType(PantallaSolicitudDespacho), findsOneWidget);
      // Con un solo ítem no se muestra la barra
      expect(find.byKey(const Key("barra_navegacion_principal")), findsNothing);
      expect(find.byKey(const Key("boton_cerrar_sesion")), findsOneWidget);
    });

    testWidgets("Credenciales inválidas no redirigen y mantienen el login", (
      tester,
    ) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("campo_usuario")), "receptor");
      await tester.enterText(
        find.byKey(const Key("campo_contrasena")),
        "incorrecta",
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key("boton_iniciar_sesion")));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaInicioSesion), findsOneWidget);
      expect(find.byKey(const Key("barra_navegacion_principal")), findsNothing);
      expect(
        find.text("Credenciales inválidas. Verifique su usuario y contraseña."),
        findsOneWidget,
      );
    });

    testWidgets("Cerrar sesión vuelve al login", (tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pumpAndSettle();

      await iniciarSesion(tester, "gestor");
      expect(find.byKey(const Key("barra_navegacion_principal")), findsOneWidget);

      await tester.tap(find.byKey(const Key("boton_cerrar_sesion")));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaInicioSesion), findsOneWidget);
      expect(find.byKey(const Key("barra_navegacion_principal")), findsNothing);
    });
  });
}