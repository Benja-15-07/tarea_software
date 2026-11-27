import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

void main() {
  group("Pruebas unitarias de SolicitudDespacho", () {
    late Map<TipoSangre, int> stockBase;
    late DateTime fechaPrueba;

    setUp(() {
      fechaPrueba = DateTime(2026, 11, 20, 10, 30);
      stockBase = {
        TipoSangre.aPositivo: 5,
        TipoSangre.oPositivo: 3,
        TipoSangre.oNegativo: 2,
      };
    });

    test("Test 1: Creación exitosa con múltiples tipos de sangre y estado Pendiente", () {
      final solicitud = SolicitudDespacho(
        id: "1000001",
        unidadesSolicitadas: {
          TipoSangre.aPositivo: 2,
          TipoSangre.oNegativo: 1,
        },
        tipoDespacho: TipoDespacho.urgente,
        stockDisponible: stockBase,
        fechaSolicitud: fechaPrueba,
      );

      expect(solicitud.id, "1000001");
      expect(solicitud.unidadesSolicitadas[TipoSangre.aPositivo], 2);
      expect(solicitud.unidadesSolicitadas[TipoSangre.oNegativo], 1);
      expect(solicitud.totalUnidades, 3);
      expect(solicitud.tipoDespacho, TipoDespacho.urgente);
      expect(solicitud.fechaSolicitud, fechaPrueba);
      expect(solicitud.estadoSolicitud, EstadoSolicitud.pendiente);
    });

    test("Test 2: Rechaza la creación cuando no hay stock disponible (stock vacío)", () {
      expect(
        () => SolicitudDespacho(
          id: "1000002",
          unidadesSolicitadas: {TipoSangre.oPositivo: 1},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: {},
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            "message",
            contains("O+"),
          ),
        ),
      );
    });

    test("Test 2b: Rechaza la creación cuando el stock es insuficiente e indica los tipos faltantes", () {
      expect(
        () => SolicitudDespacho(
          id: "1000003",
          unidadesSolicitadas: {
            TipoSangre.aPositivo: 6,
            TipoSangre.abNegativo: 1,
          },
          tipoDespacho: TipoDespacho.urgente,
          stockDisponible: stockBase,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            "message",
            allOf(contains("A+"), contains("AB-")),
          ),
        ),
      );
    });

    test("Test 3: Rechaza solicitud incompleta sin tipos de sangre", () {
      expect(
        () => SolicitudDespacho(
          id: "1000004",
          unidadesSolicitadas: {},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: stockBase,
        ),
        throwsArgumentError,
      );
    });

    test("Test 3b: Rechaza solicitud con ID vacío o cantidad menor o igual a cero", () {
      expect(
        () => SolicitudDespacho(
          id: "   ",
          unidadesSolicitadas: {TipoSangre.aPositivo: 1},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: stockBase,
        ),
        throwsArgumentError,
      );

      expect(
        () => SolicitudDespacho(
          id: "1000005",
          unidadesSolicitadas: {TipoSangre.aPositivo: 0},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: stockBase,
        ),
        throwsArgumentError,
      );
    });

    test("Actualiza estado de Pendiente a Aceptada y no permite cambios posteriores", () {
      final solicitud = SolicitudDespacho(
        id: "1000006",
        unidadesSolicitadas: {TipoSangre.oPositivo: 1},
        tipoDespacho: TipoDespacho.normal,
        stockDisponible: stockBase,
      );

      expect(solicitud.actualizarEstado(EstadoSolicitud.aceptada), isTrue);
      expect(solicitud.estadoSolicitud, EstadoSolicitud.aceptada);
      expect(solicitud.actualizarEstado(EstadoSolicitud.pendiente), isFalse);
    });

    test("El mapa de unidadesSolicitadas es inmodificable externamente", () {
      final solicitud = SolicitudDespacho(
        id: "1000007",
        unidadesSolicitadas: {TipoSangre.aPositivo: 1},
        tipoDespacho: TipoDespacho.normal,
        stockDisponible: stockBase,
      );

      expect(
        () => solicitud.unidadesSolicitadas[TipoSangre.bPositivo] = 2,
        throwsUnsupportedError,
      );
    });
  });
}