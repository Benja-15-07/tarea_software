import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_detalle_donacion.dart';

class PantallaHistorialDonaciones extends StatefulWidget {
  final RegistroDonacion registroDonacion;

  const PantallaHistorialDonaciones({
    super.key,
    required this.registroDonacion,
  });

  @override
  State<PantallaHistorialDonaciones> createState() =>
      _PantallaHistorialDonacionesState();
}

class _PantallaHistorialDonacionesState
    extends State<PantallaHistorialDonaciones> {
  @override
  Widget build(BuildContext context) {
    final historial = [...widget.registroDonacion.donaciones]..sort(
    (a, b) => b.fechaActualizacionEstado.compareTo(a.fechaActualizacionEstado),
  );

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Sistema de Gestión de Sangre"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
        actions: [
          IconButton(
            key: const Key("boton_actualizar_historial"),
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar historial",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              shadowColor: ColoresApp.sombraTarjeta,
              color: ColoresApp.superficieTarjeta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.history,
                          color: ColoresApp.primario,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Historial de Donaciones",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoPrincipal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Listado completo de unidades registradas y su estado actual. Seleccione una fila para ver el detalle.",
                      style: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 13.5,
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),
                    if (historial.isEmpty)
                      Container(
                        key: const Key("mensaje_historial_vacio"),
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ColoresApp.fondoPantalla,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: ColoresApp.textoSecundario,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Aún no hay donaciones registradas en el historial.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: ColoresApp.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        key: const Key("lista_historial_donaciones"),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: historial.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final donacion = historial[index];
                          final colorEstado = _colorEstado(donacion);
                          final etiquetaEstado = _etiquetaEstado(donacion);

                          return InkWell(
                            key: Key("fila_donacion_${donacion.id}"),
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _abrirDetalle(donacion),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ColoresApp.primario.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      donacion.tipoSangre.etiqueta,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: ColoresApp.primario,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ID: ${donacion.id} • ${donacion.volumenDonado} ml",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: ColoresApp.textoPrincipal,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Actualización: ${_formatoFechaHora(donacion.fechaActualizacionEstado)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: ColoresApp.textoSecundario,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorEstado.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      etiquetaEstado,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: colorEstado,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: ColoresApp.textoSecundario,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

   String _etiquetaEstado(Donacion donacion) {
    if (donacion.estaExpirada() &&
        donacion.estadoDonacion == EstadoDonacion.disponible) {
      return "Vencida";
    }
    switch (donacion.estadoDonacion) {
      case EstadoDonacion.disponible:
        return "Disponible";
      case EstadoDonacion.despachada:
        return "Despachada";
      case EstadoDonacion.desechada:
        return "Desechada";
    }
  }

  String _formatoFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return "$dia/$mes/${fecha.year}";
  }

  String _formatoFechaHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return "${_formatoFecha(fecha)} $hora:$minuto";
  }

  Color _colorEstado(Donacion donacion) {
    if (donacion.estaExpirada() &&
        donacion.estadoDonacion == EstadoDonacion.disponible) {
      return const Color.fromARGB(255, 255, 94, 0);
    }
    switch (donacion.estadoDonacion) {
      case EstadoDonacion.disponible:
        return Colors.green;
      case EstadoDonacion.despachada:
        return Colors.blueAccent;
      case EstadoDonacion.desechada:
        return Colors.red;
    }
  }

  void _abrirDetalle(Donacion donacion) {
    showDialog(
      context: context,
      builder: (_) => PantallaDetalleDonacion(donacion: donacion),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }
}