import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";

//Clase que representa a un donante de sangre
class Donante {
  final String rut;
  final String nombre;
  final DateTime fechaNacimiento;
  final TipoSangre tipoSangre;
  int peso;
  String telefono;
  EstadoElegibilidad _elegibilidad;

  Donante({
    required this.rut,
    required this.nombre,
    required this.fechaNacimiento,
    required this.tipoSangre,
    required this.peso,
    required this.telefono,
    required EstadoElegibilidad elegibilidad,
  }) : _elegibilidad = elegibilidad;

  //Verificar si el donante es apto para donar sangre
  bool get esApto => _elegibilidad == EstadoElegibilidad.apto;

  //Getter de elegibilidad
  EstadoElegibilidad get elegibilidad => _elegibilidad;

  //Actualizar el estado de elegibilidad del donante
  bool actualizarElegibilidad(EstadoElegibilidad nuevoEstado) {
    if (_elegibilidad == EstadoElegibilidad.noAptoPermanentemente) {
      return false; // No se puede modificar un rechazo permanente
    }
    _elegibilidad = nuevoEstado;
    return true;
  }

  //Se sobrescribe el operador == para comparar donantes por su rut
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donante && runtimeType == other.runtimeType && rut == other.rut;

  //Se sobrescribe el hashCode para que coincida con la implementación de ==
  @override
  int get hashCode => rut.hashCode;
  
  //Representación en String del donante
  @override
  String toString() {
    return "Donante{rut: $rut, nombre: $nombre, fechaNacimiento: $fechaNacimiento, tipoSangre: ${tipoSangre.etiqueta}, peso: $peso, telefono: $telefono, elegibilidad: $_elegibilidad}";
  }
}
