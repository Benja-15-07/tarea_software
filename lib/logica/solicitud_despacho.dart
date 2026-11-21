import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";

// Clase que representa una solicitud de despacho de donaciones de sangre
class SolicitudDespacho {
  final String id;
  final Map<TipoSangre, int> _unidadesSolicitadas;
  final TipoDespacho tipoDespacho;
  final DateTime fechaSolicitud;
  EstadoSolicitud _estadoSolicitud;

  SolicitudDespacho({
    required String id,
    required Map<TipoSangre, int> unidadesSolicitadas,
    required this.tipoDespacho,
    required Map<TipoSangre, int> stockDisponible,
    DateTime? fechaSolicitud,
  }) : id = validarIdSolicitud(id),
       _unidadesSolicitadas = Map.unmodifiable(
         validarUnidadesYStock(unidadesSolicitadas, stockDisponible),
       ),
       fechaSolicitud = fechaSolicitud ?? DateTime.now(),
       _estadoSolicitud = EstadoSolicitud.pendiente;

  // Retorna un mapa inmodificable con los tipos de sangre y cantidades solicitadas
  Map<TipoSangre, int> get unidadesSolicitadas => _unidadesSolicitadas;

  // Getter del estado actual de la solicitud
  EstadoSolicitud get estadoSolicitud => _estadoSolicitud;

  // Retorna el total de unidades solicitadas sumando todos los tipos de sangre
  int get totalUnidades =>
      _unidadesSolicitadas.values.fold(0, (suma, cantidad) => suma + cantidad);

  // Permite actualizar el estado de la solicitud de pendiente a aceptada
  bool actualizarEstado(EstadoSolicitud nuevoEstado) {
    if (_estadoSolicitud == EstadoSolicitud.pendiente &&
        nuevoEstado == EstadoSolicitud.aceptada) {
      _estadoSolicitud = nuevoEstado;
      return true;
    }
    return false;
  }

  // Se sobrescribe el operador == para comparar solicitudes por su id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolicitudDespacho &&
          runtimeType == other.runtimeType &&
          id == other.id;

  // Se sobrescribe el hashCode para que coincida con la implementación de ==
  @override
  int get hashCode => id.hashCode;

  // Representación en String de la solicitud de despacho
  @override
  String toString() {
    final detalle = _unidadesSolicitadas.entries
        .map((e) => "${e.key.etiqueta}: ${e.value}")
        .join(", ");
    return "SolicitudDespacho{id: $id, unidadesSolicitadas: {$detalle}, tipoDespacho: ${tipoDespacho.etiqueta}, fechaSolicitud: $fechaSolicitud, estado: ${_estadoSolicitud.etiqueta}}";
  }
}

// --- FUNCIONES DE VALIDACIÓN ---

// Valida que el ID de la solicitud no esté vacío
String validarIdSolicitud(String id) {
  final idLimpio = id.trim();
  if (idLimpio.isEmpty) {
    throw ArgumentError("El ID de la solicitud no puede estar vacío.");
  }
  return idLimpio;
}

// Valida que las unidades solicitadas estén completas, sean mayores a 0
// y existan suficientes donaciones disponibles en stock
Map<TipoSangre, int> validarUnidadesYStock(
  Map<TipoSangre, int> unidadesSolicitadas,
  Map<TipoSangre, int> stockDisponible,
) {
  if (unidadesSolicitadas.isEmpty) {
    throw ArgumentError(
      "Debe solicitar al menos un tipo de sangre con su cantidad.",
    );
  }

  for (final entry in unidadesSolicitadas.entries) {
    if (entry.value <= 0) {
      throw ArgumentError(
        "La cantidad solicitada para ${entry.key.etiqueta} debe ser mayor a 0.",
      );
    }
  }

  final List<String> tiposSinStock = [];
  for (final entry in unidadesSolicitadas.entries) {
    final disponible = stockDisponible[entry.key] ?? 0;
    if (entry.value > disponible) {
      tiposSinStock.add(
        "${entry.key.etiqueta} (solicitado: ${entry.value}, disponible: $disponible)",
      );
    }
  }

  if (tiposSinStock.isNotEmpty) {
    throw ArgumentError(
      "No hay stock suficiente para: ${tiposSinStock.join(', ')}.",
    );
  }

  return Map<TipoSangre, int>.from(unidadesSolicitadas);
}