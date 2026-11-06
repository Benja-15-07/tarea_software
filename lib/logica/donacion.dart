import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";


//Clase que representa una donacion de sangre
class Donacion{

    final String id;
    final TipoSangre tipoSangre;
    final double volumen_donado;
    final DateTime fecha_de_toma;
    final DateTime fecha_de_caducidad;
    EstadoDonacion estado_donacion;

    Donacion({

        required this.id; //id de 7 digitos 
        required this.tipo_sangre;
        required this.volumen_donado;
        required this.fecha_de_toma;
        required DateTime fecha_de_caducidad;
        required EstadoDonacion estado_donacion;
        
        
    })  : 
          estado_donacion = EstadoDonacion.disponible, //el estado inicial de la donacion es: disponible
          fecha_de_caducidad = calcularFechaCaducidad(fecha_de_toma)


    //calcula la fecha de caducidad como la fecha de toma + 42 dias despues
    static DateTime calcularFechaCaducidad(DateTime fechaToma) {

    return fechaToma.add(const Duration(days: 42));

    }
          

    //Se sobrescribe el operador == para comparar donaciones por su id
    @override
    bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donacion && runtimeType == other.runtimeType && id == other.id;

    //Se sobrescribe el hashCode para que coincida con la implementacion de ==
    @override
    int get hashCode => id.hashCode;
         

    //Representación en String del donante
    @override
    String toString() {
        return "Donacion{id: $id, tipoSangre: ${tipoSangre.etiqueta}, volumenDonado: $volumen_donado, fechaToma: $fecha_de_toma, fechaCaducidad: $fecha_de_caducidad, estado: $estado_donacion}";
    }

    

 



}