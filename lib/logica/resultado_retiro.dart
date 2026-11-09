//La clase es el resultado del retiro de una donación vencida: estado y mensaje de resultado

//enum de utilidad
enum EstadoRetiro { exitoso, noVencida, yaDesechada, noEncontrada }

class ResultadoRetiro {
  final EstadoRetiro estado;
  const ResultadoRetiro(this.estado);

  bool get fueExitoso => estado == EstadoRetiro.exitoso;

  String get mensaje {
    switch (estado) {
      case EstadoRetiro.exitoso:
        return "Donación desechada exitosamente";
      case EstadoRetiro.noVencida:
        return "No se puede retirar: la donación no está vencida";
      case EstadoRetiro.yaDesechada:
        return "No se puede retirar: la donación ya se encuentra desechada";
      case EstadoRetiro.noEncontrada:
        return "No se encontró ninguna donación con ese ID";
    }
  }
}