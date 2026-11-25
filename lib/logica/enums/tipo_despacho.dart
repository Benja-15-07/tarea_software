enum TipoDespacho {
  normal,
  urgente,
}

extension TipoDespachoExtension on TipoDespacho {
  String get etiqueta {
    switch (this) {
      case TipoDespacho.normal:
        return 'Normal';
      case TipoDespacho.urgente:
        return 'Urgente';
    }
  }
}