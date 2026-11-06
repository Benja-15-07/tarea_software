import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_donacion.dart";


//Clase que representa una donacion de sangre
class Donacion{

    final String id;
    final TipoSangre tipoSangre;
    final double volumenDonado;
    final DateTime fechaDeToma;
    final DateTime fechaDeCaducidad;
    EstadoDonacion estadoDonacion;

    Donacion({

        required this.id, //id de 7 digitos 
        required this.tipoSangre,
        required this.volumenDonado,
        required this.fechaDeToma,
        
    })  : 
          estadoDonacion = EstadoDonacion.disponible, //el estado inicial de la donacion es: disponible
          fechaDeCaducidad = calcularFechaCaducidad(fechaDeToma);


    //calcula la fecha de caducidad como la fecha de toma + 42 dias despues
    static DateTime calcularFechaCaducidad(DateTime fechaToma) {

    return fechaToma.add(const Duration(days: 42));

    }

    //Permite actualizar el estado de la donacion de disponible al nuevo
    //estado dado
    bool actualizarEstado(EstadoDonacion nuevoEstado) {

        //si el estado actual es disponible se hace el cambio
        if (estadoDonacion == EstadoDonacion.disponible) {
            estadoDonacion = nuevoEstado;
            return true;
        }

        // si el estado actual es diferente de disponible,
        // no se permite el cambio y se retorna false.
        return false; 
    }


          
    //Se sobrescribe el operador == para comparar donaciones por su id
    @override
    bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donacion && runtimeType == other.runtimeType && id == other.id;

    //se sobrescribe el hashCode para que coincida con la implementacion de ==
    @override
    int get hashCode => id.hashCode;
         

    //representacion en string de la donacion
    @override
    String toString() {
        return "Donacion{id: $id, tipoSangre: ${tipoSangre.etiqueta}, volumenDonado: $volumenDonado, fechaToma: $fechaDeToma, fechaCaducidad: $fechaDeCaducidad, estado: $estadoDonacion}";
    }

    

 



}