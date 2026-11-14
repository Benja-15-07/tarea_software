import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";

void main() {
  group("Pruebas unitarias de Donacion", () {
    late DateTime fechaToma;
    late Donacion donacion;

    setUp(() {
      fechaToma = DateTime(2026, 11, 6);
      donacion = Donacion(
        id: "1234567",
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaToma,
        rutDonante: "12345678-5",
      );
    });

    test("crea una donacion con los datos recibidos y valores calculados", () {
      expect(donacion.id, "1234567");
      expect(donacion.tipoSangre, TipoSangre.aPositivo);
      expect(donacion.volumenDonado, 450);
      expect(donacion.fechaDeToma, fechaToma);
      expect(donacion.rutDonante, "12345678-5");
      expect(
        donacion.fechaDeCaducidad,
        fechaToma.add(const Duration(days: 42)),
      );
      expect(donacion.estadoDonacion, EstadoDonacion.disponible);
    });

    test("normaliza el RUT del donante quitando espacios y pasando K a mayúscula", () {
      final donacionConK = Donacion(
        id: "1234569",
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaToma,
        rutDonante: " 16378047-k ",
      );
      expect(donacionConK.rutDonante, "16378047-K");
    });

    test("calcula la fecha de caducidad sumando 42 dias", () {
      final fechaCaducidad = Donacion.calcularFechaCaducidad(fechaToma);
      expect(fechaCaducidad, DateTime(2026, 12, 18));
    });

    test("acepta un volumen de 400 ml", () {
      final otraDonacion = Donacion(
        id: "1234568",
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 400,
        fechaDeToma: fechaToma,
        rutDonante: "12345678-5",
      );

      expect(otraDonacion.volumenDonado, 400);
    });

    test("acepta un volumen de 500 ml", () {
      final otraDonacion = Donacion(
        id: "1234568",
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 500,
        fechaDeToma: fechaToma,
        rutDonante: "12345678-5",
      );

      expect(otraDonacion.volumenDonado, 500);
    });

    test("rechaza un volumen inferior a 400 ml", () {
      expect(
        () => Donacion(
          id: "1234567",
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 399,
          fechaDeToma: fechaToma,
          rutDonante: "12345678-5",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("rechaza un volumen superior a 500 ml", () {
      expect(
        () => Donacion(
          id: "1234567",
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 501,
          fechaDeToma: fechaToma,
          rutDonante: "12345678-5",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("rechaza una fecha de toma futura", () {
      expect(
        () => Donacion(
          id: "1234567",
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 450,
          fechaDeToma: DateTime.now().add(const Duration(days: 1)),
          rutDonante: "12345678-5",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("no considera expirada una donacion vigente", () {
      expect(donacion.estaExpirada(), isFalse);
    });

    test("considera expirada una donacion cuya fecha de caducidad ya paso", () {
      final donacionExpirada = Donacion(
        id: "1234568",
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now().subtract(const Duration(days: 43)),
        rutDonante: "12345678-5",
      );

      expect(donacionExpirada.estaExpirada(), isTrue);
    });

    test("permite actualizar el estado cuando esta disponible", () {
      final actualizado = donacion.actualizarEstado(
        EstadoDonacion.desechada,
      );

      expect(actualizado, isTrue);
      expect(donacion.estadoDonacion, EstadoDonacion.desechada);
    });

    test("no permite actualizar nuevamente un estado que ya no es disponible", () {
      donacion.actualizarEstado(EstadoDonacion.desechada);

      final actualizado = donacion.actualizarEstado(
        EstadoDonacion.disponible,
      );

      expect(actualizado, isFalse);
      expect(donacion.estadoDonacion, EstadoDonacion.desechada);
    });

    test("dos donaciones con el mismo id son iguales", () {
      final otraDonacion = Donacion(
        id: "1234567",
        tipoSangre: TipoSangre.oNegativo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 7),
        rutDonante: "98765432-5",
      );

      expect(donacion, otraDonacion);
      expect(donacion.hashCode, otraDonacion.hashCode);
    });

    test("dos donaciones con distinto id no son iguales", () {
      final otraDonacion = Donacion(
        id: "7654321",
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaToma,
        rutDonante: "12345678-5",
      );

      expect(donacion, isNot(otraDonacion));
    });

    test("toString incluye los datos principales de la donacion y el rut del donante", () {
      final representacion = donacion.toString();

      expect(representacion, contains("1234567"));
      expect(representacion, contains("12345678-5"));
      expect(representacion, contains("A+"));
      expect(representacion, contains("450"));
      expect(representacion, contains("disponible"));
    });
  });
}