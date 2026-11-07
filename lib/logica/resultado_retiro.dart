//La clase es el resultado del retiro de una donación vencida: estado y mensaje de resultado

//enum de utilidad
enum EstadoRetiro { exitoso, noVencida, noEncontrada }

class ResultadoRetiro {
  final EstadoRetiro estado;
  const ResultadoRetiro._(this.estado);

  static const exitoso = ResultadoRetiro._(EstadoRetiro.exitoso);
  static const noVencida = ResultadoRetiro._(EstadoRetiro.noVencida);
  static const noEncontrada = ResultadoRetiro._(EstadoRetiro.noEncontrada);

  bool get fueExitoso => estado == EstadoRetiro.exitoso;

  String get mensaje {
    switch (estado) {
      case EstadoRetiro.exitoso:
        return "Donación retirada exitosamente.";
      case EstadoRetiro.noVencida:
        return "No se puede retirar: la donación no está vencida.";
      case EstadoRetiro.noEncontrada:
        return "No se encontró ninguna donación con ese ID.";
    }
  }
}