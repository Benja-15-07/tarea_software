import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";

void main() {
  group("Pruebas unitarias de la clase Donante", () {
    late Donante donante;
    late Donante donante2;
    late Donante donante3;
    final fechaNacimiento = DateTime(1998, 5, 20);

    setUp(() {
      donante = Donante(
        rut: "12345678-5", // DV válido Módulo 11
        nombre: "Juan Pérez",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.oPositivo,
        peso: 75,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );

      donante2 = Donante(
        rut: "12345678-5", // Mismo rut que donante
        nombre: "Juan Pérez Modificado",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.abPositivo,
        peso: 120,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );

      donante3 = Donante(
        rut: "98765432-5", // DV válido Módulo 11 diferente
        nombre: "Juan Pérez",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.oPositivo,
        peso: 75,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );
    });

    test("Crear instancia de Donante asigna correctamente sus atributos.", () {
      expect(donante.rut, "12345678-5");
      expect(donante.nombre, "Juan Pérez");
      expect(donante.fechaNacimiento, fechaNacimiento);
      expect(donante.tipoSangre, TipoSangre.oPositivo);
      expect(donante.peso, 75);
      expect(donante.telefono, "+56912345678");
      expect(donante.elegibilidad, EstadoElegibilidad.apto);
      expect(donante.esApto, isTrue);
      expect(donante.edad, greaterThanOrEqualTo(27));
    });

    test("Normaliza RUT con K mayúscula y número de telefono (+56)", () {
      final donanteConK = Donante(
        rut: "16378047-k",
        nombre: "Ana Silva",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.aPositivo,
        peso: 65,
        telefono: "912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );
      expect(donanteConK.rut, "16378047-K");
      expect(donanteConK.telefono, "+56912345678");
    });

    test("Actualizar elegibilidad funciona excepto si el donante es no apto permanentemente.", () {
      final resultado1 = donante.actualizarElegibilidad(EstadoElegibilidad.noAptoPermanentemente);
      expect(resultado1, isTrue);
      expect(donante.elegibilidad, EstadoElegibilidad.noAptoPermanentemente);

      final resultado2 = donante.actualizarElegibilidad(EstadoElegibilidad.apto);
      expect(resultado2, isFalse);
      expect(donante.elegibilidad, EstadoElegibilidad.noAptoPermanentemente);
    });

    group("Pruebas de validación de campos (Excepciones)", () {
      test("Lanza ArgumentError si el RUT es vacío, mal formado o con DV incorrecto", () {
        expect(
          () => Donante(
            rut: "12345678-9", // DV incorrecto (debería ser 5)
            nombre: "Juan Pérez",
            fechaNacimiento: fechaNacimiento,
            tipoSangre: TipoSangre.oPositivo,
            peso: 75,
            telefono: "+56912345678",
            elegibilidad: EstadoElegibilidad.apto,
          ),
          throwsArgumentError,
        );
      });

      test("Lanza ArgumentError si el nombre está vacío", () {
        expect(
          () => Donante(
            rut: "12345678-5",
            nombre: "   ",
            fechaNacimiento: fechaNacimiento,
            tipoSangre: TipoSangre.oPositivo,
            peso: 75,
            telefono: "+56912345678",
            elegibilidad: EstadoElegibilidad.apto,
          ),
          throwsArgumentError,
        );
      });

      test("Lanza ArgumentError si la edad es menor a 17 años o fecha futura", () {
        final fechaMenor = DateTime.now().subtract(const Duration(days: 365 * 10));
        expect(
          () => Donante(
            rut: "12345678-5",
            nombre: "Juan Pérez",
            fechaNacimiento: fechaMenor,
            tipoSangre: TipoSangre.oPositivo,
            peso: 75,
            telefono: "+56912345678",
            elegibilidad: EstadoElegibilidad.apto,
          ),
          throwsArgumentError,
        );
      });

      test("Lanza ArgumentError si el peso es menor o igual a 0", () {
        expect(
          () => Donante(
            rut: "12345678-5",
            nombre: "Juan Pérez",
            fechaNacimiento: fechaNacimiento,
            tipoSangre: TipoSangre.oPositivo,
            peso: -5,
            telefono: "+56912345678",
            elegibilidad: EstadoElegibilidad.apto,
          ),
          throwsArgumentError,
        );
      });

      test("Lanza ArgumentError si el teléfono tiene formato inválido", () {
        expect(
          () => Donante(
            rut: "12345678-5",
            nombre: "Juan Pérez",
            fechaNacimiento: fechaNacimiento,
            tipoSangre: TipoSangre.oPositivo,
            peso: 75,
            telefono: "12345",
            elegibilidad: EstadoElegibilidad.apto,
          ),
          throwsArgumentError,
        );
      });
    });

    group("Pruebas de igualdad y hashCode", () {
      test("Dos donantes con el mismo RUT se consideran iguales.", () {
        expect(donante, equals(donante2));
        expect(donante.hashCode, equals(donante2.hashCode));
      });

      test("Dos donantes con Rut diferente no se consideran iguales.", () {
        expect(donante, isNot(equals(donante3)));
        expect(donante.hashCode, isNot(equals(donante3.hashCode)));
      });
    });

    test('toString incluye la etiqueta formateada del tipo de sangre', () {
      final texto = donante.toString();
      expect(texto, contains('rut: 12345678-5'));
      expect(texto, contains('tipoSangre: O+'));
    });
  });
}