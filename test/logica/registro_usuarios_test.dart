import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/rol.dart";
import "package:proyecto_banco_sangre/logica/registro_usuarios.dart";
import "package:proyecto_banco_sangre/logica/usuario.dart";

void main() {
  group("Pruebas unitarias de RegistroUsuarios", () {
    late RegistroUsuarios registro;
    late Usuario usuario1;
    late Usuario usuario2;

    setUp(() {
      registro = RegistroUsuarios();
      usuario1 = Usuario(
        usuario: "juan",
        contrasena: "secreto123",
        rol: Rol.gestorInventario,
      );
      usuario2 = Usuario(
        usuario: "ana",
        contrasena: "clave456",
        rol: Rol.receptorDonaciones,
      );
    });

    test("La estructura inicia vacía al crearse", () {
      expect(registro.cantidadUsuarios, 0);
      expect(registro.usuarios, isEmpty);
    });

    test("Registrar un usuario correctamente", () {
      final resultado = registro.ingresarUsuario(usuario1);

      expect(resultado, isTrue);
      expect(registro.cantidadUsuarios, 1);
      expect(registro.usuarios, contains(usuario1));
    });

    test("Rechazar registro duplicado por nombre de usuario", () {
      registro.ingresarUsuario(usuario1);

      final duplicado = Usuario(
        usuario: "juan",
        contrasena: "otraClave",
        rol: Rol.funcionarioHospital,
      );
      final resultado = registro.ingresarUsuario(duplicado);

      expect(resultado, isFalse);
      expect(registro.cantidadUsuarios, 1);
      expect(registro.buscarPorNombre("juan")?.rol, Rol.gestorInventario);
    });

    test("Registrar varios usuarios con distinto nombre mantiene todos", () {
      registro.ingresarUsuario(usuario1);
      final resultado = registro.ingresarUsuario(usuario2);

      expect(resultado, isTrue);
      expect(registro.cantidadUsuarios, 2);
      expect(registro.usuarios, containsAll([usuario1, usuario2]));
    });

    test("Rechazar registro incompleto (instancia inválida no se construye)", () {
      expect(
        () => Usuario(
          usuario: "   ",
          contrasena: "clave",
          rol: Rol.receptorDonaciones,
        ),
        throwsArgumentError,
      );
      expect(registro.cantidadUsuarios, 0);
    });

    group("validarCredenciales", () {
      test("Retorna el rol con credenciales correctas", () {
        registro.ingresarUsuario(usuario1);

        final rol = registro.validarCredenciales("juan", "secreto123");

        expect(rol, Rol.gestorInventario);
      });

      test("Retorna null si el usuario no existe", () {
        registro.ingresarUsuario(usuario1);

        final rol = registro.validarCredenciales("maria", "secreto123");

        expect(rol, isNull);
      });

      test("Retorna null si la contraseña es incorrecta", () {
        registro.ingresarUsuario(usuario1);

        final rol = registro.validarCredenciales("juan", "incorrecta");

        expect(rol, isNull);
      });

      test("Retorna null si usuario y contraseña son incorrectos", () {
        registro.ingresarUsuario(usuario1);

        final rol = registro.validarCredenciales("maria", "incorrecta");

        expect(rol, isNull);
      });
    });

    group("buscarPorNombre y existeUsuario", () {
      test("buscarPorNombre retorna el usuario si existe o null si no", () {
        registro.ingresarUsuario(usuario1);

        expect(registro.buscarPorNombre("juan"), equals(usuario1));
        expect(registro.buscarPorNombre("maria"), isNull);
      });

      test("existeUsuario verifica correctamente la presencia de un nombre", () {
        registro.ingresarUsuario(usuario1);

        expect(registro.existeUsuario("juan"), isTrue);
        expect(registro.existeUsuario("ana"), isFalse);
      });
    });
  });
}