import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_donacion.dart';

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
        volumenDonado: 450,
        fechaDeToma: fecha,
        rutDonante: "12345678-5",
      );

      //se verifica que la cantidad de elementos en el map haya aumentado en 1
      expect(registro.cantidadDonaciones, 1);
      expect(registro.existeDonacion(id), isTrue);

      //por ultimo se comprueba que la donacion exista buscando por id
      final donacion = registro.buscarPorId(id);
      expect(donacion, isNotNull);
      expect(donacion!.id, id);
      expect(donacion.tipoSangre, TipoSangre.aPositivo);
      expect(donacion.volumenDonado, 450);
      expect(donacion.fechaDeToma, fecha);
      expect(donacion.rutDonante,"12345678-5");
    });

    test('Test 2: Preservar donaciones anteriores al agregar una nueva', () {
      
      //se registra una primera donacion
      final fechaPrimera = DateTime(2026, 10, 1);
      final idPrimera = registro.ingresarDonacion(
        tipoSangre: TipoSangre.oNegativo,
        volumenDonado: 400,
        fechaDeToma: fechaPrimera,
        rutDonante: "12345678-5",
      );

      final donacionPrimeraAntes = registro.buscarPorId(idPrimera)!;

      //se registra una segunda donación.
      final fechaSegunda = DateTime(2026, 11, 6);
      final idSegunda = registro.ingresarDonacion(
        tipoSangre: TipoSangre.abPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaSegunda,
        rutDonante: "12345678-5",
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
      expect(donacionPrimeraDespues.rutDonante, donacionPrimeraAntes.rutDonante);

      // se verifica que la 2da donacion se haya almacenado correctamente
      final donacionSegunda = registro.buscarPorId(idSegunda)!;
      expect(donacionSegunda.tipoSangre, TipoSangre.abPositivo);
      expect(donacionSegunda.volumenDonado, 450);
      expect(donacionSegunda.fechaDeToma, fechaSegunda);
      expect(donacionSegunda.rutDonante, "12345678-5");
    });

    test('Test 3: Rechazar una donación con datos inválidos', () {
      
      //se guarda la cantidad de donaciones que existen antes de ingresar una
      final cantidadInicial = registro.cantidadDonaciones;

      // se comprueba que el volumen 0 genere un ArgumentError
      expect(
        () => registro.ingresarDonacion(
          tipoSangre: TipoSangre.aPositivo,
          volumenDonado: 0,
          fechaDeToma: DateTime(2026, 11, 6),
          rutDonante: "12345678-5"
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'mensaje de error',
            'el volumen debe estar en un rango entre 400 y 500 ml',
          ),
        ),
      );

      // Se verifica que la donacion invalida no se haya añadido al registro
      expect(registro.cantidadDonaciones, cantidadInicial);
    });
  });

  test('Test 4: Evitar colisiones de IDs y preservar la donación anterior', () {

  // Se prepara una secuencia de IDs que simula una colisión.
  // El segundo ID generado será igual al primero.
  final ids = ['1234567', '1234567', '7654321'];
  int indice = 0;

  // Se crea un registro con un generador de IDs controlado.
  final registroPrueba = RegistroDonacion(
    generarId: () {
      String id = ids[indice];
      indice++;
      return id;
    },
  );

  // Se registra la primera donación.
  final idPrimera = registroPrueba.ingresarDonacion(
    tipoSangre: TipoSangre.oNegativo,
    volumenDonado: 450,
    fechaDeToma: DateTime(2026, 11, 6),
    rutDonante: "12345678-5",
  );

  final donacionPrimeraAntes = registroPrueba.buscarPorId(idPrimera)!;

  // Se registra la segunda donación.
  // El generador primero intentará utilizar un ID repetido.
  final idSegunda = registroPrueba.ingresarDonacion(
    tipoSangre: TipoSangre.aPositivo,
    volumenDonado: 450,
    fechaDeToma: DateTime(2026, 11, 6),
    rutDonante: "12345678-5",
  );

  // Se comprueba que la primera donación recibió el primer ID.
  expect(idPrimera, '1234567');

  // Se comprueba que, ante la colisión, se generó otro ID.
  expect(idSegunda, '7654321');
  expect(idSegunda, isNot(idPrimera));

  // Se comprueba que ambas donaciones siguen almacenadas.
  expect(registroPrueba.cantidadDonaciones, 2);
  expect(registroPrueba.existeDonacion(idPrimera), isTrue);
  expect(registroPrueba.existeDonacion(idSegunda), isTrue);

  // Se comprueba que la primera donación no fue reemplazada.
  final donacionPrimeraDespues = registroPrueba.buscarPorId(idPrimera)!;

  expect(donacionPrimeraDespues.id, donacionPrimeraAntes.id);
  expect(donacionPrimeraDespues.tipoSangre, donacionPrimeraAntes.tipoSangre);
  expect(donacionPrimeraDespues.volumenDonado, donacionPrimeraAntes.volumenDonado);
  expect(donacionPrimeraDespues.rutDonante, donacionPrimeraAntes.rutDonante);

  // Se comprueba que la segunda donación se almacenó con sus datos.
  final donacionSegunda = registroPrueba.buscarPorId(idSegunda)!;

  expect(donacionSegunda.tipoSangre, TipoSangre.aPositivo);
  expect(donacionSegunda.volumenDonado, 450);
});

group('Agrupación y Orden por Caducidad', () {
    late RegistroDonacion registroT;

    setUp(() {
      registroT = RegistroDonacion();
    });

    test('Test 1: Agrupar unidades correctamente', () {
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 1),
        rutDonante: "12345678-5",
      );
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 2),
        rutDonante: "87654321-K",
      );
      final stockAgrupado = registroT.obtenerStockAgrupadoYOrdenado();

      expect(stockAgrupado[TipoSangre.oPositivo]?.length, 1);
      expect(stockAgrupado[TipoSangre.aPositivo]?.length, 1);
      expect(stockAgrupado[TipoSangre.bPositivo]?.length, 0);
    });

    test('Test 2: Mantener unidades del mismo tipo agrupadas', () {
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 1),
        rutDonante: "12345678-5",
      );
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 500,
        fechaDeToma: DateTime(2026, 11, 2),
        rutDonante: "87654321-K",
      );

      final stockAgrupado = registroT.obtenerStockAgrupadoYOrdenado();

      expect(stockAgrupado[TipoSangre.oPositivo]?.length, 2);
    });

    test('Test 1: Ordenar unidades por caducidad', () {
      final fechaAntigua = DateTime(2026, 10, 1); 
      final fechaReciente = DateTime(2026, 11, 5); 

      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaReciente,
        rutDonante: "12345678-5",
      );
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: fechaAntigua,
        rutDonante: "87654321-K",
      );

      final ordenadas = registroT.getDonacionesDisponiblesOrdenadasPorCaducidad();

      expect(ordenadas.length, 2);
      expect(ordenadas.first.fechaDeToma, fechaAntigua);
      expect(ordenadas.last.fechaDeToma, fechaReciente);
    });

    test('Test 2: Ordenar unidades con la misma fecha de caducidad', () {
      final mismaFecha = DateTime(2026, 10, 1);

      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: mismaFecha,
        rutDonante: "12345678-5",
      );
      registroT.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 500,
        fechaDeToma: mismaFecha,
        rutDonante: "87654321-K",
      );

      final ordenadas = registroT.getDonacionesDisponiblesOrdenadasPorCaducidad();

      expect(ordenadas.length, 2);
    });
  });

  group('calculo y actualización de stock por tipo', () {
    late RegistroDonacion registroT9;

    setUp(() {
      registroT9 = RegistroDonacion();
    });

    test('test 1: Calcular stock correctamente', () {
      registroT9.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 1),
        rutDonante: "12345678-5",
      );
      registroT9.ingresarDonacion(
        tipoSangre: TipoSangre.aPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 2),
        rutDonante: "87654321-K",
      );

      final stock = registroT9.calcularStockPorTipo();

      expect(stock[TipoSangre.oPositivo], 1);
      expect(stock[TipoSangre.aPositivo], 1);
      expect(stock[TipoSangre.bPositivo], 0);
    });

    test('test 2: Excluir unidades no disponibles', () {
      final id = registroT9.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 1),
        rutDonante: "12345678-5",
      );

      expect(registroT9.calcularStockPorTipo()[TipoSangre.oPositivo], 1);

      final cambio = registroT9.actualizarEstadoDonacion(id, EstadoDonacion.despachada);
      expect(cambio, isTrue);

      final stock = registroT9.calcularStockPorTipo();
      expect(stock[TipoSangre.oPositivo], 0);
    });

    test('test 3: Actualizar cantidades del stock', () {
      registroT9.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 1),
        rutDonante: "12345678-5",
      );

      var stockAntes = registroT9.calcularStockPorTipo();
      expect(stockAntes[TipoSangre.oPositivo], 1);

      registroT9.ingresarDonacion(
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime(2026, 11, 2),
        rutDonante: "87654321-K",
      );

      var stockDespues = registroT9.calcularStockPorTipo();
      expect(stockDespues[TipoSangre.oPositivo], 2);
    });
  });

  
}


