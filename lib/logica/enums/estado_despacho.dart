enum EstadoDespacho {
  generado,
  despachado,
}

extension EstadoDespachoExtension on EstadoDespacho {
  String get etiqueta {
    switch (this) {
      case EstadoDespacho.generado:
        return "generado";
      case EstadoDespacho.despachado:
        return "despachado";
    }
  }
}