import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart";

void main() {
  group("Pruebas unitarias de RegistroSolicitudDespacho", () {
    late RegistroDonacion registroDonacion;
    late RegistroSolicitudDespacho registroSolicitudes;

    setUp(() {
      registroDonacion = RegistroDonacion();
      registroSolicitudes = RegistroSolicitudDespacho(
        registroDonacion: registroDonacion,
      );
    });

    void agregarDonaciones(TipoSangre tipo, int cantidad) {
      for (int i = 0; i < cantidad; i++) {
        registroDonacion.ingresarDonacion(
          tipoSangre: tipo,
          volumenDonado: 450,
          fechaDeToma: DateTime.now(),
          rutDonante: "12345678-5",
        );
      }
    }

    test("Test 1: Registro exitoso cuando hay stock suficiente", () {
      agregarDonaciones(TipoSangre.oPositivo, 3);
      agregarDonaciones(TipoSangre.aNegativo, 2);

      final id = registroSolicitudes.ingresarSolicitud(
        unidadesSolicitadas: {
          TipoSangre.oPositivo: 2,
          TipoSangre.aNegativo: 1,
        },
        tipoDespacho: TipoDespacho.urgente,
      );

      expect(registroSolicitudes.cantidadSolicitudes, 1);
      expect(registroSolicitudes.existeSolicitud(id), isTrue);

      final solicitud = registroSolicitudes.buscarPorId(id);
      expect(solicitud, isNotNull);
      expect(solicitud!.id, id);
      expect(solicitud.estadoSolicitud, EstadoSolicitud.pendiente);
      expect(solicitud.tipoDespacho, TipoDespacho.urgente);
      expect(solicitud.unidadesSolicitadas[TipoSangre.oPositivo], 2);
      expect(solicitud.unidadesSolicitadas[TipoSangre.aNegativo], 1);
    });

    test("Test 2: Rechaza el registro cuando no existen donaciones en inventario", () {
      expect(registroSolicitudes.hayDonacionesDisponibles, isFalse);

      expect(
        () => registroSolicitudes.ingresarSolicitud(
          unidadesSolicitadas: {TipoSangre.aPositivo: 1},
          tipoDespacho: TipoDespacho.normal,
        ),
        throwsArgumentError,
      );

      expect(registroSolicitudes.cantidadSolicitudes, 0);
    });

    test("Test 2b: Rechaza el registro cuando el stock es insuficiente para el tipo solicitado", () {
      agregarDonaciones(TipoSangre.oPositivo, 1);

      expect(
        () => registroSolicitudes.ingresarSolicitud(
          unidadesSolicitadas: {TipoSangre.oPositivo: 2},
          tipoDespacho: TipoDespacho.normal,
        ),
        throwsArgumentError,
      );

      expect(registroSolicitudes.cantidadSolicitudes, 0);
    });

    test("No considera donaciones despachadas o desechadas como stock disponible", () {
      final idDonacion = registroDonacion.ingresarDonacion(
        tipoSangre: TipoSangre.bPositivo,
        volumenDonado: 450,
        fechaDeToma: DateTime.now(),
        rutDonante: "12345678-5",
      );
      registroDonacion.actualizarEstadoDonacion(
        idDonacion,
        EstadoDonacion.despachada,
      );

      expect(registroSolicitudes.hayDonacionesDisponibles, isFalse);
      expect(
        () => registroSolicitudes.ingresarSolicitud(
          unidadesSolicitadas: {TipoSangre.bPositivo: 1},
          tipoDespacho: TipoDespacho.urgente,
        ),
        throwsArgumentError,
      );
      expect(registroSolicitudes.cantidadSolicitudes, 0);
    });

    test("Genera IDs únicos incluso si el generador repite un valor", () {
      agregarDonaciones(TipoSangre.aPositivo, 5);

      final idsPrueba = ["1111111", "1111111", "2222222"];
      int indice = 0;

      final registroConGenerador = RegistroSolicitudDespacho(
        registroDonacion: registroDonacion,
        generarId: () => idsPrueba[indice++],
      );

      final id1 = registroConGenerador.ingresarSolicitud(
        unidadesSolicitadas: {TipoSangre.aPositivo: 1},
        tipoDespacho: TipoDespacho.normal,
      );
      final id2 = registroConGenerador.ingresarSolicitud(
        unidadesSolicitadas: {TipoSangre.aPositivo: 1},
        tipoDespacho: TipoDespacho.urgente,
      );

      expect(id1, "1111111");
      expect(id2, "2222222");
      expect(registroConGenerador.cantidadSolicitudes, 2);
    });

    test("Actualiza estado de solicitud y filtra pendientes ordenadas por fecha", () {
      agregarDonaciones(TipoSangre.oNegativo, 5);

      final idMasReciente = registroSolicitudes.ingresarSolicitud(
        unidadesSolicitadas: {TipoSangre.oNegativo: 1},
        tipoDespacho: TipoDespacho.normal,
        fechaSolicitud: DateTime(2026, 11, 20, 15, 0),
      );
      final idMasAntigua = registroSolicitudes.ingresarSolicitud(
        unidadesSolicitadas: {TipoSangre.oNegativo: 1},
        tipoDespacho: TipoDespacho.urgente,
        fechaSolicitud: DateTime(2026, 11, 20, 9, 0),
      );

      final pendientes =
          registroSolicitudes.getSolicitudesPendientesOrdenadasPorFecha();
      expect(pendientes.length, 2);
      expect(pendientes.first.id, idMasAntigua);
      expect(pendientes.last.id, idMasReciente);

      expect(
        registroSolicitudes.actualizarEstadoSolicitud(
          idMasAntigua,
          EstadoSolicitud.aceptada,
        ),
        isTrue,
      );
      expect(
        registroSolicitudes.getSolicitudesPendientesOrdenadasPorFecha().length,
        1,
      );
    });
  });
}