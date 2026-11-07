enum EstadoElegibilidad {
  apto,
  noAptoTemporalmente,
  noAptoPermanentemente,
}

extension EstadoElegibilidadExtension on EstadoElegibilidad {
  String get etiqueta {
    switch (this) {
      case EstadoElegibilidad.apto:
        return 'Apto';
      case EstadoElegibilidad.noAptoTemporalmente:
        return 'No apto temporalmente';
      case EstadoElegibilidad.noAptoPermanentemente:
        return 'No apto permanentemente';
    }
  }
}
