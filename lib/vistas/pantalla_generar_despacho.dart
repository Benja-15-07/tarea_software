import "package:flutter/material.dart";
import "package:proyecto_banco_sangre/logica/despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_despacho.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";

class PantallaGenerarDespacho extends StatefulWidget {
  final SolicitudDespacho solicitud;
  final RegistroDespacho registroDespacho;

  const PantallaGenerarDespacho({
    super.key,
    required this.solicitud,
    required this.registroDespacho,
  });

  @override
  State<PantallaGenerarDespacho> createState() => _PantallaGenerarDespachoState();
}

class _PantallaGenerarDespachoState extends State<PantallaGenerarDespacho> {
  Despacho? _despachoGenerado;
  String? _mensajeError;

  void _confirmarGeneracionDespacho() {
    setState(() {
      _mensajeError = null;
    });

    try {
      final despacho = widget.registroDespacho.generarDespacho(
        widget.solicitud,
      );
      setState(() {
        _despachoGenerado = despacho;
        _mensajeError = null;
      });
    } catch (e) {
      final textoError = e.toString().replaceFirst(
        RegExp(r"^(Invalid argument( \(.*\))?: |Bad state: )"),
        "",
      );
      setState(() {
        _mensajeError = textoError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.solicitud;
    final estadoEtiqueta = solicitud.estadoSolicitud.etiqueta;
    final yaDespachada =
        solicitud.estadoSolicitud == EstadoSolicitud.despachada;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Generar despacho"),
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tarjetaDetalleSolicitud(solicitud, estadoEtiqueta),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                key: const Key("boton_generar_despacho"),
                onPressed: yaDespachada ? null : _confirmarGeneracionDespacho,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  foregroundColor: ColoresApp.textoSobrePrimario,
                  disabledBackgroundColor: ColoresApp.botonDeshabilitadoFondo,
                  disabledForegroundColor: ColoresApp.botonDeshabilitadoTexto,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.local_shipping),
                label: Text(
                  yaDespachada ? "Solicitud despachada" : "Generar despacho",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_mensajeError != null) ...[
              const SizedBox(height: 16),
              _tarjetaAlertaError(_mensajeError!),
            ],
            if (_despachoGenerado != null) ...[
              const SizedBox(height: 16),
              _tarjetaComprobanteDespacho(_despachoGenerado!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tarjetaDetalleSolicitud(
    SolicitudDespacho solicitud,
    String estadoEtiqueta,
  ) {
    final esPendiente = solicitud.estadoSolicitud == EstadoSolicitud.pendiente;

    return Card(
      color: ColoresApp.superficieTarjeta,
      elevation: 2,
      shadowColor: ColoresApp.sombraTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresApp.primario, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detalle de solicitud",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoPrincipal,
              ),
            ),
            const Divider(color: ColoresApp.primario, thickness: 1.5),
            _filaDato("ID Solicitud:", solicitud.id),
            _filaDato("Tipo de despacho:", solicitud.tipoDespacho.etiqueta),
            _filaDato("Fecha solicitud:", _formatoFechaHora(solicitud.fechaSolicitud)),
            _filaDato(
              "Estado:",
              estadoEtiqueta,
              keyValor: const Key("estado_solicitud_texto"),
              colorValor: esPendiente ? ColoresApp.primario : ColoresApp.exito,
            ),
            const SizedBox(height: 8),
            const Text(
              "Unidades solicitadas:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColoresApp.textoPrincipal,
              ),
            ),
            const SizedBox(height: 6),
            ...solicitud.unidadesSolicitadas.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.etiqueta,
                      style: const TextStyle(color: ColoresApp.textoPrincipal),
                    ),
                    Text(
                      "${entry.value} ${entry.value == 1 ? 'unidad' : 'unidades'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaAlertaError(String mensaje) {
    return Container(
      key: const Key("alerta_falta_stock"),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresApp.error, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: ColoresApp.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No se pudo generar el despacho",
                  style: TextStyle(
                    color: ColoresApp.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: const TextStyle(color: ColoresApp.textoPrincipal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaComprobanteDespacho(Despacho despacho) {
    return Card(
      key: const Key("comprobante_despacho"),
      color: ColoresApp.superficieTarjeta,
      elevation: 2,
      shadowColor: ColoresApp.sombraTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresApp.exito, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: ColoresApp.exito),
                SizedBox(width: 8),
                Text(
                  "Comprobante de despacho",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.exito,
                  ),
                ),
              ],
            ),
            const Divider(color: ColoresApp.exito, thickness: 1.5),
            _filaDato("ID Despacho:", despacho.id),
            _filaDato(
              "Fecha de despacho:",
              _formatoFechaHora(despacho.fechaDespacho),
            ),
            _filaDato("Estado despacho:", despacho.estadoTexto),
            _filaDato(
              "Total unidades asignadas:",
              "${despacho.cantidadUnidades}",
            ),
            const SizedBox(height: 8),
            const Text(
              "Unidades asignadas:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColoresApp.textoPrincipal,
              ),
            ),
            const SizedBox(height: 6),
            ...despacho.unidadesAsignadas.map(
              (unidad) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  "• ID ${unidad.id} (${unidad.tipoSangre.etiqueta} - ${unidad.volumenDonado} ml)",
                  style: const TextStyle(color: ColoresApp.textoPrincipal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDato(
    String etiqueta,
    String valor, {
    Key? keyValor,
    Color? colorValor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(color: ColoresApp.textoSecundario),
          ),
          Text(
            valor,
            key: keyValor,
            style: TextStyle(
              color: colorValor ?? ColoresApp.textoPrincipal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatoFechaHora(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, "0");
    final mes = fecha.month.toString().padLeft(2, "0");
    final hora = fecha.hour.toString().padLeft(2, "0");
    final minuto = fecha.minute.toString().padLeft(2, "0");
    return "$dia/$mes/${fecha.year} $hora:$minuto";
  }
}