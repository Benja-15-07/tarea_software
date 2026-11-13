import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donantes.dart";
import "dart:math";

class RegistroDonacion{
  
  //map de donaciones que usa el id como clave
  final Map<String, Donacion> _donaciones = {};

  //vuncion que se encarga de generar los IDs
  final String Function() _generarId;

  // constructor: si no se recibe una funcion generadora,
  // se utiliza el generador aleatorio.
  RegistroDonacion({String Function()? generarId})
    : _generarId = generarId ?? _generarIdAleatorio;


  //retorna una lista inmodificable de donaciones
  List<Donacion> get donaciones => List.unmodifiable(_donaciones.values);
  
  //entrega la cantidad de donaciones
  int get cantidadDonaciones => _donaciones.length;


  //crea una instancia de Donacion segun los parametros dados, la ingresa
  //al map de donaciones y retorna el id generado
  String ingresarDonacion({
    required TipoSangre tipoSangre,
    required int volumenDonado,
    required DateTime fechaDeToma,
    required String rutDonante,
    }){
    
    String id;

    //se genera un id hasta encontrar uno que no este ocupado por otra donacion
    //del map
    do {id = _generarId();} while (_donaciones.containsKey(id));

    //se crea la instancia de donacion con los argumentos dados y el id generado
    final donacion = Donacion(
        id: id,
        tipoSangre: tipoSangre,
        volumenDonado: volumenDonado,
        fechaDeToma: fechaDeToma,
        rutDonante: rutDonante,

    );

    // se almacena la donacion
    _donaciones[id] = donacion;

    return id;   

  }



  //busca una donacion, retorna null si no existe.
  Donacion? buscarPorId(String id){
    return _donaciones[id];
  }

  //verifica si existe una donacion ocupando el id dado en el
  //map de donaciones, retorna true si existe
  bool existeDonacion(String id){
    return _donaciones.containsKey(id);
    
  }

  //actualiza el estado de una donacion registrada dado su id
  bool actualizarEstadoDonacion(String id, EstadoDonacion nuevoEstado){

    final donacion = _donaciones[id];
    if (donacion == null){
        return false;
    }

    return donacion.actualizarEstado(nuevoEstado);
  }


  //genera un numero de 7 digitos entre 1000000 y 9999999 y lo convierte a String 
  //para utilizarlo como id

  static String _generarIdAleatorio() {
    Random random = Random();
    int numero = 1000000 + random.nextInt(9000000);

    return numero.toString();
  }

}





