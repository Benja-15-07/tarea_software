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
      );
    });

    test("crea una donacion con los datos recibidos y valores calculados", () {
      expect(donacion.id, "1234567");
      expect(donacion.tipoSangre, TipoSangre.aPositivo);
      expect(donacion.volumenDonado, 450);
      expect(donacion.fechaDeToma, fechaToma);
      expect(
        donacion.fechaDeCaducidad,
        fechaToma.add(const Duration(days: 42)),
      );
      expect(donacion.estadoDonacion, EstadoDonacion.disponible);
    });

    test("calcula la fecha de caducidad sumando 42 dias", () {
      final fechaCaducidad = Donacion.calcularFechaCaducidad(fechaToma);

      expect(fechaCaducidad, DateTime(2026, 12, 18));
    });

    test("rechaza un volumen igual a cero", () {
      expect(
        () => Donacion(
          id: "1234567",
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 0,
          fechaDeToma: fechaToma,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            "message",
            "el volumen debe tener valor positivo",
          ),
        ),
      );
    });

    test("rechaza un volumen negativo", () {
      expect(
        () => Donacion(
          id: "1234567",
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: -10,
          fechaDeToma: fechaToma,
        ),
        throwsA(isA<ArgumentError>()),
      );
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
        volumenDonado: 300,
        fechaDeToma: DateTime(2026, 11, 7),
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
      );

      expect(donacion, isNot(otraDonacion));
    });

    test("toString incluye los datos principales de la donacion", () {
      final representacion = donacion.toString();

      expect(representacion, contains("1234567"));
      expect(representacion, contains("A+"));
      expect(representacion, contains("450.0"));
      expect(representacion, contains("disponible"));
    });
  });
}
