enum TipoSangre {
  aPositivo,
  aNegativo,
  bPositivo,
  bNegativo,
  abPositivo,
  abNegativo,
  oPositivo,
  oNegativo,
}

extension TipoSangreExtension on TipoSangre {
  String get etiqueta {
    switch (this) {
      case TipoSangre.aPositivo: return 'A+';
      case TipoSangre.aNegativo: return 'A-';
      case TipoSangre.bPositivo: return 'B+';
      case TipoSangre.bNegativo: return 'B-';
      case TipoSangre.abPositivo: return 'AB+';
      case TipoSangre.abNegativo: return 'AB-';
      case TipoSangre.oPositivo: return 'O+';
      case TipoSangre.oNegativo: return 'O-';
    }
  }
}