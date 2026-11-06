import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";

class RegistroDonantes {
  //Mapa Rut - Donante
  final Map<String, Donante> _donantes = {};

  //Retorna una lista inmodificable
  List<Donante> get donantes => List.unmodifiable(_donantes.values);
  
  //Entrega la cantidad de donantes
  int get cantidadDonantes => _donantes.length;

  //Ingresa un donante y retorna false si el rut coincide con otro registrado
  bool ingresarDonante(Donante donante) {
    if (_donantes.containsKey(donante.rut)) {
      return false;
    }
    _donantes[donante.rut] = donante;
    return true;
  }

  //Busca un donante, retorna null si no existe.
  Donante? buscarPorRut(String rut) {
  final rutNormalizado = validarYNormalizarRut(rut);
  return _donantes[rutNormalizado];
}

  //Verifica un rut en sistema.
  bool existeDonante(String rut) {
    return _donantes.containsKey(rut);
  }

  // Actualiza la elegibilidad de un donante registrado según su RUT.
  bool actualizarElegibilidadDonante(String rut, EstadoElegibilidad nuevoEstado) {
  final donante = _donantes[rut];
  if (donante == null) {
    return false;
  }
  return donante.actualizarElegibilidad(nuevoEstado);
}
}