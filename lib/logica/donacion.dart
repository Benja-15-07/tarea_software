import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";

// Clase que representa una donación de sangre
class Donacion {
  final String id;
  final TipoSangre tipoSangre;
  final int volumenDonado;
  final DateTime fechaDeToma;
  final DateTime fechaDeCaducidad;
  EstadoDonacion estadoDonacion;
  final String rutDonante;

  Donacion({
    required this.id, // id de 7 dígitos
    required this.tipoSangre,
    required int volumenDonado,
    required String rutDonante,
    required DateTime fechaDeToma,
  }) : estadoDonacion = EstadoDonacion.disponible,
       rutDonante = rutDonante.trim().toUpperCase(),
       fechaDeToma = validarFechaDeToma(fechaDeToma),
       fechaDeCaducidad = calcularFechaCaducidad(
         validarFechaDeToma(fechaDeToma),
       ),
       volumenDonado = validarVolumen(volumenDonado);

  // Calcula la fecha de caducidad como la fecha de toma + 42 días después
  static DateTime calcularFechaCaducidad(DateTime fechaToma) {
    final fechaLimpia = DateTime(
      fechaToma.year,
      fechaToma.month,
      fechaToma.day,
    );
    return fechaLimpia.add(const Duration(days: 42));
  }

  // Permite actualizar el estado de la donación de disponible al nuevo estado dado
  bool actualizarEstado(EstadoDonacion nuevoEstado) {
    if (estadoDonacion == EstadoDonacion.disponible) {
      estadoDonacion = nuevoEstado;
      return true;
    }
    return false;
  }

  // Devuelve true en caso de que la donación haya pasado su fecha de caducidad
  bool estaExpirada() {
    final ahora = DateTime.now();
    final hoyLimpio = DateTime(ahora.year, ahora.month, ahora.day);
    final caducidadLimpia = DateTime(
      fechaDeCaducidad.year,
      fechaDeCaducidad.month,
      fechaDeCaducidad.day,
    );
    return hoyLimpio.isAfter(caducidadLimpia);
  }

  // Se sobrescribe el operador == para comparar donaciones por su id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donacion && runtimeType == other.runtimeType && id == other.id;

  // Se sobrescribe el hashCode para que coincida con la implementación de ==
  @override
  int get hashCode => id.hashCode;

  // Representación en string de la donación
  @override
  String toString() {
    return "Donacion{id: $id, rutDonante: $rutDonante, tipoSangre: ${tipoSangre.etiqueta}, volumenDonado: $volumenDonado, fechaToma: $fechaDeToma, fechaCaducidad: $fechaDeCaducidad, estado: $estadoDonacion}";
  }
}

// Valida que la fecha de toma no sea posterior a la fecha actual y la normaliza (año, mes, día)
DateTime validarFechaDeToma(DateTime fecha) {
  final ahora = DateTime.now();
  final fechaLimpia = DateTime(fecha.year, fecha.month, fecha.day);
  final hoyLimpio = DateTime(ahora.year, ahora.month, ahora.day);

  if (fechaLimpia.isAfter(hoyLimpio)) {
    throw ArgumentError("la fecha de toma no puede ser futura");
  }
  return fechaLimpia;
}

// Valida el volumen donado
int validarVolumen(int volumen) {
  if (volumen < 400 || volumen > 500) {
    throw ArgumentError("el volumen debe estar en un rango entre 400 y 500 ml");
  }
  return volumen;
}