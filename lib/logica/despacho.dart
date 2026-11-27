import "dart:math";
import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

class Despacho {
  final String id;
  final String solicitudId;
  final List<Donacion> _unidadesAsignadas;
  final DateTime fechaDespacho;
  EstadoDespacho _estado;

  Despacho({
    required SolicitudDespacho solicitud,
    required List<Donacion>? unidadesAsignadas,
    DateTime? fechaDespacho,
    String Function()? generarId,
  }) : solicitudId = validarSolicitudPendiente(solicitud).id,
       _unidadesAsignadas = List.unmodifiable(
         validarUnidadesAsignadas(unidadesAsignadas),
       ),
       fechaDespacho = fechaDespacho ?? DateTime.now(),
       _estado = EstadoDespacho.generado,
       id = (generarId ?? _generarIdAleatorio)();

  List<Donacion> get unidadesAsignadas => _unidadesAsignadas;

  List<String> get idsUnidadesAsignadas =>
      List.unmodifiable(_unidadesAsignadas.map((d) => d.id));

  EstadoDespacho get estado => _estado;

  String get estadoTexto => _estado.etiqueta;

  int get cantidadUnidades => _unidadesAsignadas.length;

  void marcarComoDespachado() {
    if (_estado == EstadoDespacho.generado) {
      _estado = EstadoDespacho.despachado;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Despacho && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final ids = idsUnidadesAsignadas.join(", ");
    return "Despacho{id: $id, solicitudId: $solicitudId, unidades: [$ids], fechaDespacho: $fechaDespacho, estado: ${_estado.etiqueta}}";
  }

  static String _generarIdAleatorio() {
    final random = Random();
    final numero = 1000000 + random.nextInt(9000000);
    return numero.toString();
  }
}

SolicitudDespacho validarSolicitudPendiente(SolicitudDespacho solicitud) {
  if (solicitud.estadoSolicitud != EstadoSolicitud.pendiente) {
    throw StateError(
      "La solicitud asociada debe estar en estado Pendiente para crear un despacho.",
    );
  }
  return solicitud;
}

List<Donacion> validarUnidadesAsignadas(List<Donacion>? unidades) {
  if (unidades == null || unidades.isEmpty) {
    throw ArgumentError(
      "El despacho debe contener al menos una unidad de sangre.",
    );
  }

  for (final donacion in unidades) {
    if (donacion.estadoDonacion != EstadoDonacion.disponible) {
      throw ArgumentError(
        "La unidad de sangre ${donacion.id} no está disponible para asignar.",
      );
    }
  }

  return List<Donacion>.from(unidades);
}