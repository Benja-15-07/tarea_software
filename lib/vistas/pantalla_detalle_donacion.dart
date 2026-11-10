import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';

class PantallaDetalleDonacion extends StatelessWidget{
  final Donacion donacion;

  const PantallaDetalleDonacion({
    super.key,
    required this.donacion
  });

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: const Text("Detalle de donación", textAlign: TextAlign.center,),
      backgroundColor: ColoresApp.fondoPantalla,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: ColoresApp.primario,
          width: 3,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              color: ColoresApp.primario,
              thickness: 2,
              
            ),
            if(donacion.estaExpirada())
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 210, 2),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Vencida",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            _detalleDato("ID:", donacion.id),
            _detalleDato("Tipo de sangre:", donacion.tipoSangre.etiqueta),
            _detalleDato("Volumen donado:", "${donacion.volumenDonado} ml"),
            _detalleDato("Fecha de toma:", _formatoFecha(donacion.fechaDeToma)),
            _detalleDato("Fecha de caducidad:", _formatoFecha(donacion.fechaDeCaducidad)),
            _detalleDato("Estado:", donacion.estaExpirada() 
              ? "Vencida" : donacion.estadoDonacion.name,
              colorValor: donacion.estaExpirada() ? const Color.fromARGB(255, 255, 94, 0) : null
            ),
          ],
        ),
      ),
    );
  }

  Widget _detalleDato(String etiqueta, String valor, {Color? colorValor}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: ColoresApp.textoPrincipal),
            )),
          Text(
            valor,
            style: TextStyle(
              color: colorValor ?? ColoresApp.textoPrincipal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatoFecha(DateTime fecha){
    int dia = fecha.day;
    int mes = fecha.month;
    int year = fecha.year;
    return "$dia/$mes/$year";
  }
}