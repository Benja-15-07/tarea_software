import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/donante.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/registro_donantes.dart';

void main() {
  group('Pruebas unitarias de RegistroDonantes', () {
    late RegistroDonantes registro;
    late Donante donante1;
    late Donante donante2;
    final fechaNacimiento = DateTime(1998, 5, 20);

    setUp(() {
      registro = RegistroDonantes();
      donante1 = Donante(
        rut: '12345678-9',
        nombre: 'Juan Pérez',
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.oPositivo,
        peso: 75,
        telefono: '+56912345678',
        elegibilidad: EstadoElegibilidad.apto,
      );
      donante2 = Donante(
        rut: '98765432-1',
        nombre: 'María Soto',
        fechaNacimiento: DateTime(2001, 10, 12),
        tipoSangre: TipoSangre.aNegativo,
        peso: 62,
        telefono: '+56987654321',
        elegibilidad: EstadoElegibilidad.noAptoTemporalmente,
      );
    });

    test('La estructura inicia vacía al crearse', () {
      expect(registro.cantidadDonantes, 0);
      expect(registro.donantes, isEmpty);
    });

    test('Ingresar un donante nuevo en un registro vacío retorna true y lo almacena', () {
      final resultado = registro.ingresarDonante(donante1);

      expect(resultado, isTrue);
      expect(registro.cantidadDonantes, 1);
      expect(registro.donantes, contains(donante1));
    });

    test('Ingresar múltiples donantes con distinto RUT mantiene todos los registros intactos', () {
      registro.ingresarDonante(donante1);
      final resultadoSegundo = registro.ingresarDonante(donante2);

      expect(resultadoSegundo, isTrue);
      expect(registro.cantidadDonantes, 2);
      expect(registro.donantes, containsAll([donante1, donante2]));
    });

    test('Rechaza ingresar un donante cuyo RUT ya existe en el sistema', () {
      registro.ingresarDonante(donante1);

      // Instancia distinta pero con el mismo RUT que donante1
      final donanteDuplicado = Donante(
        rut: '12345678-9',
        nombre: 'Juan Pérez Duplicado',
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.bPositivo,
        peso: 80,
        telefono: '+56900000000',
        elegibilidad: EstadoElegibilidad.noAptoPermanentemente,
      );

      final resultado = registro.ingresarDonante(donanteDuplicado);

      expect(resultado, isFalse);
      expect(registro.cantidadDonantes, 1);
      expect(registro.buscarPorRut('12345678-9')?.nombre, 'Juan Pérez');
    });

    test('buscarPorRut devuelve el donante si está registrado o null si no existe', () {
      registro.ingresarDonante(donante1);

      expect(registro.buscarPorRut('12345678-9'), equals(donante1));
      expect(registro.buscarPorRut('11111111-1'), isNull);
    });

    test('existeDonante verifica correctamente la presencia de un RUT en el sistema', () {
      registro.ingresarDonante(donante1);

      expect(registro.existeDonante('12345678-9'), isTrue);
      expect(registro.existeDonante('98765432-1'), isFalse);
    });
  });
}