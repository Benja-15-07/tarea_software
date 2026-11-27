import "dart:math";
import "package:proyecto_banco_sangre/logica/despacho.dart";
import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

class RegistroDespacho {
  final RegistroDonacion _registroDonacion;
  final Map<String, Despacho> _despachos = {};
  final String Function() _generarId;

  RegistroDespacho({
    required RegistroDonacion registroDonacion,
    String Function()? generarId,
  }) : _registroDonacion = registroDonacion,
       _generarId = generarId ?? _generarIdAleatorio;

  List<Despacho> get despachos => List.unmodifiable(_despachos.values);

  int get cantidadDespachos => _despachos.length;

  Despacho? buscarPorId(String id) {
    return _despachos[id];
  }

  bool existeDespacho(String id) {
    return _despachos.containsKey(id);
  }

  /// Genera un despacho a partir de una solicitud en estado Pendiente:

  Despacho generarDespacho(
    SolicitudDespacho solicitud, {
    DateTime? fechaDespacho,
  }) {
    if (solicitud.estadoSolicitud != EstadoSolicitud.pendiente) {
      throw StateError(
        "La solicitud ${solicitud.id} debe estar en estado Pendiente para generar un despacho.",
      );
    }

    // Obtiene unidades disponibles ya ordenadas por fechaDeCaducidad ascendente
    final stockAgrupado = _registroDonacion.obtenerStockAgrupadoYOrdenado();

    final List<Donacion> unidadesSeleccionadas = [];
    final List<String> tiposSinStock = [];

    for (final entry in solicitud.unidadesSolicitadas.entries) {
      final tipoSangre = entry.key;
      final cantidadRequerida = entry.value;

      // Filtra solo las unidades vigentes (no expiradas)
      final vigentesDisponibles = (stockAgrupado[tipoSangre] ?? [])
          .where((donacion) => !donacion.estaExpirada())
          .toList();

      if (vigentesDisponibles.length < cantidadRequerida) {
        tiposSinStock.add(
          "${tipoSangre.etiqueta} (solicitado: $cantidadRequerida, disponible vigente: ${vigentesDisponibles.length})",
        );
      } else {
        unidadesSeleccionadas.addAll(
          vigentesDisponibles.take(cantidadRequerida),
        );
      }
    }

    if (tiposSinStock.isNotEmpty) {
      throw ArgumentError(
        "No hay stock suficiente para completar la solicitud: ${tiposSinStock.join(', ')}.",
      );
    }

    String idDespacho;
    do {
      idDespacho = _generarId();
    } while (_despachos.containsKey(idDespacho));

    final despacho = Despacho(
      solicitud: solicitud,
      unidadesAsignadas: unidadesSeleccionadas,
      fechaDespacho: fechaDespacho,
      generarId: () => idDespacho,
    );

    // Actualizar estado de las unidades en el inventario a despachada
    for (final unidad in unidadesSeleccionadas) {
      _registroDonacion.actualizarEstadoDonacion(
        unidad.id,
        EstadoDonacion.despachada,
      );
    }

    // Actualizar estado de la solicitud a Despachada
    solicitud.actualizarEstado(EstadoSolicitud.despachada);

    _despachos[despacho.id] = despacho;
    return despacho;
  }

  static String _generarIdAleatorio() {
    final random = Random();
    final numero = 1000000 + random.nextInt(9000000);
    return numero.toString();
  }
}