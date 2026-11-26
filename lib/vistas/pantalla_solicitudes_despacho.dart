import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';
import 'package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/solicitud_despacho.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart';

class PantallaSolicitudesDespacho extends StatefulWidget {
  //el mapa con las solicitudes de despacho
  final Map<String, SolicitudDespacho> solicitudesDespacho;

  //se obtiene el mapa de solicitudes de despacho por el constructor
  const PantallaSolicitudesDespacho({
    super.key,
    required this.solicitudesDespacho,
  });

  @override
  State<PantallaSolicitudesDespacho> createState() =>
      _PantallaSolicitudesDespachoState();
}

class _PantallaSolicitudesDespachoState
    extends State<PantallaSolicitudesDespacho> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,

      appBar: AppBar(
        title: const Text("Solicitudes de despacho"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: ListView(
          children: [
            // categoria despacho urgente
            _construirCategoria(
              titulo: "Despacho urgente",
              subtitulo: "Solicitudes que requieren atención urgente",
              icono: Icons.priority_high,

              //se obtiene y asigna el map de solicitudes urgentes
              solicitudes: obtenerSolicitudesPorTipo(TipoDespacho.urgente),
            ),

            const SizedBox(height: 16),

            // categoria despacho normal
            _construirCategoria(
              titulo: "Despacho normal",
              subtitulo: "Solicitudes de despacho normal",
              icono: Icons.local_shipping_outlined,

              //se obtiene y asigna el map de solicitudes urgentes
              solicitudes: obtenerSolicitudesPorTipo(TipoDespacho.normal),
            ),
          ],
        ),
      ),
    );
  }

  //tarjeta desplegable, la cual al cliquearse muestra las solicitudes
  //(urgentes o normales)
  Widget _construirCategoria({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Map<String, SolicitudDespacho> solicitudes,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: ColoresApp.superficieTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoSobrePrimario,
          child: Icon(icono),
        ),

        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoPrincipal,
          ),
        ),

        subtitle: Text(
          "$subtitulo · ${solicitudes.length} solicitudes",
          style: const TextStyle(color: ColoresApp.textoSecundario),
        ),

        children: [
          const Divider(height: 1, thickness: 1),

          if (solicitudes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "No hay solicitudes de despacho pendientes",
                style: TextStyle(color: ColoresApp.textoSecundario),
              ),
            )
          else
            ...solicitudes.values.map(
              (solicitud) => _construirTarjetaSolicitud(solicitud),
            ),
        ],
      ),
    );
  }

  //el widget de la solicitud
  Widget _construirTarjetaSolicitud(SolicitudDespacho solicitud) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ColoresApp.superficieTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: ColoresApp.textoSecundario.withValues(alpha: 0.2),
        ),
      ),

      child: ListTile(
        title: Text(
          "Solicitud #${solicitud.id}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoPrincipal,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fecha: ${solicitud.fechaSolicitud}"),
            ],
          ),
        ),

        trailing: Chip(
          label: Text(
            solicitud.estadoSolicitud.etiqueta!,
            style: const TextStyle(
              fontSize: 10,
              color: ColoresApp.textoSobrePrimario,
            ),
          ),
          backgroundColor: ColoresApp.primario,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  //se toma el map de solicitudesDespacho dado al constructor y se retorna
  //un hashmap con solo las solicitudes del tipo dado por parametro
  Map<String, SolicitudDespacho> obtenerSolicitudesPorTipo(TipoDespacho tipo) {
    final Map<String, SolicitudDespacho> solicitudes = {};

    //si el tipo de la solicitud es el tipo dado por parametro, la solicitud
    //se añade al nuevo map
    for (var solicitud in widget.solicitudesDespacho.values) {
      if (solicitud.tipoDespacho == tipo && 
      solicitud.estadoSolicitud == EstadoSolicitud.pendiente) {
        solicitudes[solicitud.id] = solicitud;
      }
    }

    //se convierten las solicitudes del map en una lista.
    final listaSolicitudes = solicitudes.values.toList();

    //se ordenan las solicitudes por fechaSolicitud, estando las mas 
    //antiguas primero
    listaSolicitudes.sort(
      (a, b) => a.fechaSolicitud.compareTo(b.fechaSolicitud),
    );

    //se reconstruye el map respetando el orden de la lista
    final Map<String, SolicitudDespacho> solicitudesOrdenadas = {};

    for (var solicitud in listaSolicitudes) {
      solicitudesOrdenadas[solicitud.id] = solicitud;
    }

    return solicitudesOrdenadas;

  }
}
