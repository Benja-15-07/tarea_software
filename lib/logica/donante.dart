import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";

//Clase que representa a un donante de sangre
class Donante {
  final String rut;
  final String nombre;
  final DateTime fechaNacimiento;
  final TipoSangre tipoSangre;
  double _peso;
  String _telefono;
  EstadoElegibilidad _elegibilidad;

  Donante({
    required String rut,
    required String nombre,
    required DateTime fechaNacimiento,
    required this.tipoSangre,
    required double peso,
    required String telefono,
    required EstadoElegibilidad elegibilidad,
  }) :  rut = validarYNormalizarRut(rut),
        nombre = validarNombre(nombre),
        fechaNacimiento = validarFechaNacimiento(fechaNacimiento),
        _peso = validarPeso(peso),
        _telefono = validarYNormalizarTelefono(telefono),
        _elegibilidad = elegibilidad;


  //Getter para edad.
  int get edad => calcularEdad(fechaNacimiento);

  //Getter y Setter de peso
  double get peso => _peso;
  set peso(double nuevoPeso) => _peso = validarPeso(nuevoPeso);

  //Getter y Setter de número de telefono.
  String get telefono => _telefono;
  set telefono(String nuevoTelefono) => _telefono = validarYNormalizarTelefono(nuevoTelefono);

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

//FUNCIONES AUXILIARES

//Función auxiliar que verifica que un rut sea valido y cumpla con el formato 12345678-9
bool esRutValido(String rutRecibido) {
  //Se limpia por si el usuario escribió espacios.
  final rut = rutRecibido.trim();
  //Validar estructura exacta: 7 u 8 dígitos (sin empezar en 0), guion y DV (0-9 o K/k)
  final regexFormato = RegExp(r"^[1-9]\d{6,7}-[\dkK]$");
  if (!regexFormato.hasMatch(rut)) {
    return false;
  }

  //Separar cuerpo y dígito verificador (normalizado a mayúscula)
  final partes = rut.split("-");
  final cuerpo = partes[0];
  final dvIngresado = partes[1].toUpperCase();

  //Calcular Módulo 11 de derecha a izquierda
  int suma = 0;
  int multiplicador = 2;

  for (int i = cuerpo.length - 1; i >= 0; i--) {
    final digito = int.parse(cuerpo[i]);
    suma += digito * multiplicador;
    multiplicador = (multiplicador == 7) ? 2 : multiplicador + 1;
  }

  final resto = 11 - (suma % 11);
  final String dvEsperado;
  if (resto == 11) {
    dvEsperado = "0";
  } else if (resto == 10) {
    dvEsperado = "K";
  } else {
    dvEsperado = resto.toString();
  }

  //Comparar DV ingresado con el calculado
  return dvIngresado == dvEsperado;
}


//Valida el rut y añade normalización para almacenar con K mayúscula como estándar.
//Excepción si el Rut está vació o no cumple formato.
String validarYNormalizarRut(String rut) {
  if (rut.trim().isEmpty) {
    throw ArgumentError("El RUT no puede estar vacío.");
  }
  if (!esRutValido(rut)) {
    throw ArgumentError(
      "El RUT ingresado no tiene un formato válido (ej: 12345678-K) o su dígito verificador es incorrecto.",
    );
  }
  return rut.trim().toUpperCase();
}


/// Calcula la edad exacta a la fecha de hoy.
int calcularEdad(DateTime fechaNacimiento) {
  final hoy = DateTime.now();
  int edad = hoy.year - fechaNacimiento.year;

  // Si aún no cumple, se resta 1 año
  if (hoy.month < fechaNacimiento.month ||
      (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
    edad--;
  }
  return edad;
}

//Valida que el nombre no esté vacío.
String validarNombre(String nombre) {
  if (nombre.trim().isEmpty) {
    throw ArgumentError("El nombre no puede estar vacío.");
  }
  return nombre.trim();
}

// Valida rango edad (17 a 70 años) y fecha no futura.
/// Retorna la fecha normalizada (solo año, mes y día) o lanza ArgumentError.
DateTime validarFechaNacimiento(DateTime fechaNacimiento) {
  final hoy = DateTime.now();
  // Normalizamos quitando horas, minutos y segundos
  final fechaLimpia = DateTime(
    fechaNacimiento.year,
    fechaNacimiento.month,
    fechaNacimiento.day,
  );
  final hoyLimpio = DateTime(hoy.year, hoy.month, hoy.day);

  if (fechaLimpia.isAfter(hoyLimpio)) {
    throw ArgumentError("La fecha de nacimiento no puede ser una fecha futura.");
  }

  final edad = calcularEdad(fechaLimpia);

  if (edad < 17) {
    throw ArgumentError(
      "El donante debe tener al menos 17 años (edad actual: $edad años).",
    );
  }

  if (edad > 70) {
    throw ArgumentError(
      "El donante supera la edad máxima permitida de 70 años (edad actual: $edad años).",
    );
  }

  return fechaLimpia;
}

// Valida el peso
double validarPeso(double peso) {
  if (peso <= 0 || peso > 300) {
    throw ArgumentError("Ingrese un peso válido mayor a 0 kg.");
  }
  return peso;
}

// Valida un formato de teléfono
String validarYNormalizarTelefono(String telefonoRecibido) {
  final telefono = telefonoRecibido.trim();
  final regexTelefono = RegExp(r"^(\+56)? ?9\d{8}$");
  if (!regexTelefono.hasMatch(telefono)) {
    throw ArgumentError(
      "El teléfono ingresado no tiene un formato válido (ej: +56912345678 o 912345678).",
    );
  }
  final sinEspacios = telefono.replaceAll(" ", "");
  return sinEspacios.startsWith("+56") ? sinEspacios : "+56$sinEspacios";
}