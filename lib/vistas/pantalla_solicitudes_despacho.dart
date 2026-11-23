
import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';

class PantallaSolicitudesDespacho extends StatefulWidget {
  const PantallaSolicitudesDespacho({super.key});

  @override
  State<PantallaSolicitudesDespacho> createState() =>
      _PantallaSolicitudesDespachoState();
}

class _PantallaSolicitudesDespachoState
    extends State<PantallaSolicitudesDespacho> {

  //placeholders de las tarjetas
  final List<Map<String, String>> solicitudesUrgentes = [
    {
      'id': '001',
      'fecha': '23/11/2026',
      'tipo': 'O+',
      'volumen': '450 ml',
      'estado': 'Pendiente',
    },
    {
      'id': '002',
      'fecha': '23/11/2026',
      'tipo': 'A-',
      'volumen': '300 ml',
      'estado': 'Pendiente',
    },
  ];

  final List<Map<String, String>> solicitudesNormales = [
    {
      'id': '003',
      'fecha': '23/11/2026',
      'tipo': 'B+',
      'volumen': '350 ml',
      'estado': 'Pendiente',
    },
  ];

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
              solicitudes: solicitudesUrgentes,
            ),

            const SizedBox(height: 16),

            // categoria despacho normal
            _construirCategoria(
              titulo: "Despacho normal",
              subtitulo: "Solicitudes de despacho normal",
              icono: Icons.local_shipping_outlined,
              solicitudes: solicitudesNormales,
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
    required List<Map<String, String>> solicitudes,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: ColoresApp.superficieTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

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
          style: const TextStyle(
            color: ColoresApp.textoSecundario,
          ),
        ),

        children: [
          const Divider(height: 1, thickness: 1),

          if (solicitudes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "No hay solicitudes de despacho.",
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                ),
              ),
            )
          else
            ...solicitudes.map(
              (solicitud) => _construirTarjetaSolicitud(solicitud),
            ),
        ],
      ),
    );
  }

  //el widget de la solicitud 
  Widget _construirTarjetaSolicitud(
    Map<String, String> solicitud,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      color: ColoresApp.superficieTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: ColoresApp.textoSecundario.withValues(alpha: 0.2),
        ),
      ),

      child: ListTile(
        title: Text(
          "Solicitud #${solicitud['id']}",
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
              Text("Fecha: ${solicitud['fecha']}"),
              Text("Grupo sanguíneo: ${solicitud['tipo']}"),
              Text("Volumen solicitado: ${solicitud['volumen']}"),
            ],
          ),
        ),

        trailing: Chip(
          label: Text(
            solicitud['estado']!,
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
}
