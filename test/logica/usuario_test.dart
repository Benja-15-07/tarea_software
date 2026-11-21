import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/rol.dart";
import "package:proyecto_banco_sangre/logica/usuario.dart";

void main() {
  group("Pruebas unitarias de la clase Usuario", () {
    late Usuario usuario;

    setUp(() {
      usuario = Usuario(
        usuario: "lucas",
        contrasena: "secreto123",
        rol: Rol.gestorInventario,
      );
    });

    test("Crear instancia de Usuario asigna correctamente sus atributos.", () {
      expect(usuario.usuario, "lucas");
      expect(usuario.contrasena, "secreto123");
      expect(usuario.rol, Rol.gestorInventario);
    });

    test("Normaliza el nombre de usuario quitando espacios.", () {
      final u = Usuario(
        usuario: "  benjamin  ",
        contrasena: "clave",
        rol: Rol.receptorDonaciones,
      );
      expect(u.usuario, "benjamin");
    });

    group("Pruebas de validación de campos (Excepciones)", () {
      test("Lanza ArgumentError si el nombre de usuario está vacío", () {
        expect(
          () => Usuario(
            usuario: "   ",
            contrasena: "clave",
            rol: Rol.receptorDonaciones,
          ),
          throwsArgumentError,
        );
      });

      test("Lanza ArgumentError si la contraseña está vacía", () {
        expect(
          () => Usuario(
            usuario: "lucas",
            contrasena: "",
            rol: Rol.gestorInventario,
          ),
          throwsArgumentError,
        );
      });
    });

    group("Pruebas de igualdad y hashCode", () {
      test("Dos usuarios con el mismo nombre de usuario son iguales.", () {
        final otro = Usuario(
          usuario: "lucas",
          contrasena: "otraClave",
          rol: Rol.funcionarioHospital,
        );
        expect(usuario, equals(otro));
        expect(usuario.hashCode, equals(otro.hashCode));
      });

      test("Dos usuarios con distinto nombre no son iguales.", () {
        final otro = Usuario(
          usuario: "martin",
          contrasena: "secreto123",
          rol: Rol.gestorInventario,
        );
        expect(usuario, isNot(equals(otro)));
      });
    });

    test("toString incluye el usuario y el rol, pero no la contraseña", () {
      final texto = usuario.toString();
      expect(texto, contains("lucas"));
      expect(texto, contains("Gestor de Inventario"));
      expect(texto, isNot(contains("secreto123")));
    });
  });
}