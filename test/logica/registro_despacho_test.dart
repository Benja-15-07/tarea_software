import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_despacho.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

void main() {
  group("Pruebas unitarias de RegistroDespacho (T15)", () {
    late RegistroDonacion registroDonacion;
    late RegistroDespacho registroDespacho;

    setUp(() {
      registroDonacion = RegistroDonacion();
      registroDespacho = RegistroDespacho(
        registroDonacion: registroDonacion,
      );
    });

    test(
      "Prueba 1: Generación exitosa de despacho actualiza inventario y solicitud",
      () {
        final hoy = DateTime.now();

        // 3 unidades O+ vigentes en estado disponible con distintas fechas de toma
        final idMasAntigua = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 20)),
          rutDonante: "11111111-1",
        );
        final idIntermedia = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 10)),
          rutDonante: "22222222-2",
        );
        final idMasReciente = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.oPositivo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 2)),
          rutDonante: "33333333-3",
        );

        final solicitud = SolicitudDespacho(
          id: "5000001",
          unidadesSolicitadas: {TipoSangre.oPositivo: 2},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: registroDonacion.calcularStockPorTipo(),
        );

        final despacho = registroDespacho.generarDespacho(solicitud);

        expect(registroDespacho.cantidadDespachos, 1);
        expect(despacho.solicitudId, "5000001");
        expect(despacho.estado, EstadoDespacho.generado);
        expect(despacho.unidadesAsignadas.length, 2);

        // Prioriza las 2 próximas a vencer (tomas más antiguas)
        expect(despacho.idsUnidadesAsignadas, [idMasAntigua, idIntermedia]);

        // Las 2 unidades seleccionadas pasan a estado despachada y la 3ra sigue disponible
        expect(
          registroDonacion.buscarPorId(idMasAntigua)!.estadoDonacion,
          EstadoDonacion.despachada,
        );
        expect(
          registroDonacion.buscarPorId(idIntermedia)!.estadoDonacion,
          EstadoDonacion.despachada,
        );
        expect(
          registroDonacion.buscarPorId(idMasReciente)!.estadoDonacion,
          EstadoDonacion.disponible,
        );

        // La solicitud cambia su estado a Despachada
        expect(solicitud.estadoSolicitud, EstadoSolicitud.despachada);
        expect(solicitud.estadoSolicitud.etiqueta, "Despachada");
      },
    );

    test(
      "Prueba 2: Rechazar despacho por stock vigente insuficiente sin modificar inventario ni solicitud",
      () {
        final hoy = DateTime.now();

        // Solo 1 unidad AB- vigente disponible en el inventario
        final idUnidadUnica = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.abNegativo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 5)),
          rutDonante: "44444444-4",
        );

        final solicitud = SolicitudDespacho(
          id: "5000002",
          unidadesSolicitadas: {TipoSangre.abNegativo: 3},
          tipoDespacho: TipoDespacho.urgente,
          stockDisponible: {TipoSangre.abNegativo: 3},
        );

        expect(
          () => registroDespacho.generarDespacho(solicitud),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message.toString(),
              "message",
              contains("No hay stock suficiente"),
            ),
          ),
        );

        // No se genera ningún despacho
        expect(registroDespacho.cantidadDespachos, 0);

        // El inventario no sufre modificaciones
        expect(
          registroDonacion.buscarPorId(idUnidadUnica)!.estadoDonacion,
          EstadoDonacion.disponible,
        );

        // La solicitud sigue en estado Pendiente
        expect(solicitud.estadoSolicitud, EstadoSolicitud.pendiente);
      },
    );

    test(
      "No considera unidades expiradas como stock vigente disponible",
      () {
        final hoy = DateTime.now();

        final idVigente = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.abNegativo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 10)),
          rutDonante: "11111111-1",
        );
        final idExpirada1 = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.abNegativo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 43)),
          rutDonante: "22222222-2",
        );
        final idExpirada2 = registroDonacion.ingresarDonacion(
          tipoSangre: TipoSangre.abNegativo,
          volumenDonado: 450,
          fechaDeToma: hoy.subtract(const Duration(days: 50)),
          rutDonante: "33333333-3",
        );

        final solicitud = SolicitudDespacho(
          id: "5000003",
          unidadesSolicitadas: {TipoSangre.abNegativo: 2},
          tipoDespacho: TipoDespacho.normal,
          stockDisponible: {TipoSangre.abNegativo: 3},
        );

        expect(
          () => registroDespacho.generarDespacho(solicitud),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message.toString(),
              "message",
              contains("No hay stock suficiente"),
            ),
          ),
        );

        expect(registroDespacho.cantidadDespachos, 0);
        expect(
          registroDonacion.buscarPorId(idVigente)!.estadoDonacion,
          EstadoDonacion.disponible,
        );
        expect(
          registroDonacion.buscarPorId(idExpirada1)!.estadoDonacion,
          EstadoDonacion.disponible,
        );
        expect(
          registroDonacion.buscarPorId(idExpirada2)!.estadoDonacion,
          EstadoDonacion.disponible,
        );
      },
    );
  });
}