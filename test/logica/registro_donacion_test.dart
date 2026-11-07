import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';

void main() {
  group('Pruebas unitarias de RegistroDonacion', () {
    late RegistroDonacion registro;

    setUp(() {
      // Se crea un registro nuevo antes de cada prueba.
      registro = RegistroDonacion();
    });

    test('Test 1: Almacenar una donacion válida', () {
      final fecha = DateTime(2026, 11, 6);

      //se guarda la donacion en el map vacio
      final id = registro.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450.0,
        fechaDeToma: fecha,
      );

      //se verifica que la cantidad de elementos en el map haya aumentado en 1
      expect(registro.cantidadDonaciones, 1);
      expect(registro.existeDonacion(id), isTrue);

      //por ultimo se comprueba que la donacion exista buscando por id
      final donacion = registro.buscarPorId(id);
      expect(donacion, isNotNull);
      expect(donacion!.id, id);
      expect(donacion.tipoSangre, TipoSangre.aPositivo);
      expect(donacion.volumenDonado, 450.0);
      expect(donacion.fechaDeToma, fecha);
    });

    test('Test 2: Preservar donaciones anteriores al agregar una nueva', () {
      
      //se registra una primera donacion
      final fechaPrimera = DateTime(2026, 10, 1);
      final idPrimera = registro.ingresarDonacion(
        tipoSangre: TipoSangre.oNegativo,
        volumenDonado: 400.0,
        fechaDeToma: fechaPrimera,
      );

      final donacionPrimeraAntes = registro.buscarPorId(idPrimera)!;

      //se registra una segunda donación.
      final fechaSegunda = DateTime(2026, 11, 6);
      final idSegunda = registro.ingresarDonacion(
        tipoSangre: TipoSangre.abPositivo,
        volumenDonado: 450.0,
        fechaDeToma: fechaSegunda,
      );

      // se verifica que ambas siguan registradas.
      expect(registro.cantidadDonaciones, 2);
      expect(registro.existeDonacion(idPrimera), isTrue);
      expect(registro.existeDonacion(idSegunda), isTrue);

      // se verifica que la primera donacion no haya cambiado
      final donacionPrimeraDespues = registro.buscarPorId(idPrimera)!;
      expect(donacionPrimeraDespues.id, donacionPrimeraAntes.id);
      expect(donacionPrimeraDespues.tipoSangre, donacionPrimeraAntes.tipoSangre);
      expect(donacionPrimeraDespues.volumenDonado, donacionPrimeraAntes.volumenDonado);
      expect(donacionPrimeraDespues.fechaDeToma, donacionPrimeraAntes.fechaDeToma);

      // se verifica que la 2da donacion se haya almacenado correctamente
      final donacionSegunda = registro.buscarPorId(idSegunda)!;
      expect(donacionSegunda.tipoSangre, TipoSangre.abPositivo);
      expect(donacionSegunda.volumenDonado, 450.0);
      expect(donacionSegunda.fechaDeToma, fechaSegunda);
    });

    test('Test 3: Rechazar una donación con datos inválidos', () {
      
      //se guarda la cantidad de donaciones que existen antes de ingresar una
      final cantidadInicial = registro.cantidadDonaciones;

      // se comprueba que el volumen 0 genere un ArgumentError
      expect(
        () => registro.ingresarDonacion(
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 0.0,
          fechaDeToma: DateTime(2026, 11, 6),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'mensaje de error',
            'el volumen debe tener valor positivo',
          ),
        ),
      );

      // Se verifica que la donacion invalida no se haya añadido al registro
      expect(registro.cantidadDonaciones, cantidadInicial);
    });
  });
}
