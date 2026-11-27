import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/despacho.dart";
import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

void main() {
  group("Pruebas unitarias de Despacho (T14)", () {
    late SolicitudDespacho solicitudPendiente;
    late Donacion donacion1;
    late Donacion donacion2;

    setUp(() {
      solicitudPendiente = SolicitudDespacho(
        id: "9000001",
        unidadesSolicitadas: {TipoSangre.oPositivo: 2},
        tipoDespacho: TipoDespacho.normal,
        stockDisponible: {TipoSangre.oPositivo: 5},
        fechaSolicitud: DateTime(2026, 11, 20),
      );

      donacion1 = Donacion(
        id: "1111111",
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        rutDonante: "12345678-5",
        fechaDeToma: DateTime(2026, 11, 1),
      );

      donacion2 = Donacion(
        id: "2222222",
        tipoSangre: TipoSangre.oPositivo,
        volumenDonado: 450,
        rutDonante: "12345678-5",
        fechaDeToma: DateTime(2026, 11, 2),
      );
    });

    test(
      "Prueba 1: Creación correcta de despacho con id, fecha actual y estado inicial generado",
      () {
        final antes = DateTime.now();

        final despacho = Despacho(
          solicitud: solicitudPendiente,
          unidadesAsignadas: [donacion1, donacion2],
        );

        final despues = DateTime.now();

        expect(despacho.id, isNotEmpty);
        expect(despacho.id.length, 7);
        expect(despacho.solicitudId, solicitudPendiente.id);
        expect(despacho.unidadesAsignadas.length, 2);
        expect(despacho.idsUnidadesAsignadas, ["1111111", "2222222"]);
        expect(despacho.estado, EstadoDespacho.generado);
        expect(despacho.estadoTexto, "generado");
        expect(despacho.fechaDespacho.compareTo(antes) >= 0, isTrue);
        expect(despacho.fechaDespacho.compareTo(despues) <= 0, isTrue);
      },
    );

    test(
      "Prueba 2a: Rechazar despacho con lista de unidades vacía",
      () {
        expect(
          () => Despacho(
            solicitud: solicitudPendiente,
            unidadesAsignadas: [],
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message.toString(),
              "message",
              contains("al menos una unidad de sangre"),
            ),
          ),
        );
      },
    );

    test(
      "Prueba 2b: Rechazar despacho con lista de unidades nula",
      () {
        expect(
          () => Despacho(
            solicitud: solicitudPendiente,
            unidadesAsignadas: null,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message.toString(),
              "message",
              contains("al menos una unidad de sangre"),
            ),
          ),
        );
      },
    );

    test(
      "Rechaza despacho si la solicitud asociada no está en estado Pendiente",
      () {
        solicitudPendiente.actualizarEstado(EstadoSolicitud.aceptada);

        expect(
          () => Despacho(
            solicitud: solicitudPendiente,
            unidadesAsignadas: [donacion1],
          ),
          throwsStateError,
        );
      },
    );
  });
}