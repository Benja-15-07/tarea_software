enum EstadoSolicitud {
  pendiente,
  aceptada,
  despachada,
}

extension EstadoSolicitudExtension on EstadoSolicitud {
  String get etiqueta {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.aceptada:
        return 'Aceptada';
      case EstadoSolicitud.despachada:
        return 'Despachada';
    }
  }
}