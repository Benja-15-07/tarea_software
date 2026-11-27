import "package:flutter/material.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_solicitud_despacho.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";

class PantallaSolicitudDespacho extends StatefulWidget {
  final RegistroSolicitudDespacho registroSolicitudDespacho;

  const PantallaSolicitudDespacho({
    super.key,
    required this.registroSolicitudDespacho,
  });

  @override
  State<PantallaSolicitudDespacho> createState() =>
      _PantallaSolicitudDespachoState();
}

class _PantallaSolicitudDespachoState extends State<PantallaSolicitudDespacho> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _resetDropdownTipoKey = 0;

  final _cantidadController = TextEditingController();

  TipoSangre? _tipoSangreSeleccionado;
  TipoDespacho? _tipoDespachoSeleccionado;
  final Map<TipoSangre, int> _unidadesSolicitadas = {};

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Map<TipoSangre, int> get _stockActual =>
      widget.registroSolicitudDespacho.obtenerStockDisponible();

  bool get _hayDonacionesDisponibles =>
      widget.registroSolicitudDespacho.hayDonacionesDisponibles;

  // Tipos de sangre que aún no han sido agregados a la solicitud actual
  List<TipoSangre> get _tiposDisponiblesParaAgregar => TipoSangre.values
      .where((tipo) => !_unidadesSolicitadas.containsKey(tipo))
      .toList();

  // --- Validaciones de línea a agregar ---

  String? _validarCampoCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "Ingrese una cantidad.";
    }
    final cantidad = int.tryParse(valor.trim());
    if (cantidad == null || cantidad <= 0) {
      return "Ingrese un entero mayor a 0.";
    }
    if (_tipoSangreSeleccionado != null) {
      final disponible = _stockActual[_tipoSangreSeleccionado!] ?? 0;
      if (cantidad > disponible) {
        return "Stock insuficiente (disponible: $disponible).";
      }
    }
    return null;
  }

  bool get _puedeAgregarLinea {
    if (_tipoSangreSeleccionado == null) return false;
    if (_unidadesSolicitadas.containsKey(_tipoSangreSeleccionado)) return false;
    return _validarCampoCantidad(_cantidadController.text) == null;
  }

  // --- Validación general del formulario ---

  bool get _formularioEsValido {
    if (!_hayDonacionesDisponibles) return false;
    if (_unidadesSolicitadas.isEmpty) return false;
    if (_tipoDespachoSeleccionado == null) return false;

    final stock = _stockActual;
    for (final entry in _unidadesSolicitadas.entries) {
      final disponible = stock[entry.key] ?? 0;
      if (entry.value > disponible) {
        return false;
      }
    }
    return true;
  }

  // --- Acciones ---

  void _mostrarMensaje(String texto, {required Color color}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _agregarTipoSangre() {
    final tipo = _tipoSangreSeleccionado;
    if (tipo == null) {
      _mostrarMensaje(
        "Seleccione un tipo de sangre antes de agregar.",
        color: ColoresApp.error,
      );
      return;
    }

    if (_unidadesSolicitadas.containsKey(tipo)) {
      _mostrarMensaje(
        "El tipo de sangre ${tipo.etiqueta} ya fue agregado a la solicitud.",
        color: ColoresApp.error,
      );
      return;
    }

    final errorCantidad = _validarCampoCantidad(_cantidadController.text);
    if (errorCantidad != null) {
      _mostrarMensaje(errorCantidad, color: ColoresApp.error);
      return;
    }

    final cantidad = int.parse(_cantidadController.text.trim());

    setState(() {
      _unidadesSolicitadas[tipo] = cantidad;
      _tipoSangreSeleccionado = null;
      _resetDropdownTipoKey++;
      _cantidadController.clear();
    });
  }

  void _eliminarTipoSangre(TipoSangre tipo) {
    setState(() {
      _unidadesSolicitadas.remove(tipo);
    });
  }

  void _enviarSolicitud() {
    if (!_formularioEsValido) return;

    try {
      final idSolicitud = widget.registroSolicitudDespacho.ingresarSolicitud(
        unidadesSolicitadas: Map<TipoSangre, int>.from(_unidadesSolicitadas),
        tipoDespacho: _tipoDespachoSeleccionado!,
      );

      _mostrarMensaje(
        "Solicitud registrada exitosamente (ID: $idSolicitud)",
        color: ColoresApp.exito,
      );
      _limpiarFormulario();
    } on ArgumentError catch (e) {
      _mostrarMensaje(
        e.message.toString(),
        color: ColoresApp.error,
      );
    }
  }

  void _limpiarFormulario() {
    _cantidadController.clear();
    setState(() {
      _unidadesSolicitadas.clear();
      _tipoSangreSeleccionado = null;
      _tipoDespachoSeleccionado = null;
      _resetDropdownTipoKey++;
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stock = _stockActual;
    final hayDonaciones = _hayDonacionesDisponibles;
    final tiposDisponibles = _tiposDisponiblesParaAgregar;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Sistema de Gestión de Sangre"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              elevation: 4,
              shadowColor: ColoresApp.sombraTarjeta,
              color: ColoresApp.superficieTarjeta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Encabezado del formulario
                      const Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: ColoresApp.primario,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Solicitud de Despacho",
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
                        "Agregue uno o más tipos de sangre con sus cantidades y seleccione la urgencia del despacho.",
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13.5,
                        ),
                      ),
                      const Divider(height: 32, thickness: 1),

                      // Aviso si no hay donaciones disponibles en el banco
                      if (!hayDonaciones) ...[
                        Container(
                          key: const Key("alerta_sin_donaciones"),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColoresApp.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColoresApp.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: ColoresApp.error,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "No hay donaciones disponibles en el inventario. No es posible enviar solicitudes en este momento.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ColoresApp.textoPrincipal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Selector de Urgencia / Tipo de Despacho
                      DropdownButtonFormField<TipoDespacho>(
                        key: const Key("dropdown_tipo_despacho"),
                        isExpanded: true,
                        initialValue: _tipoDespachoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: "Urgencia del despacho",
                          prefixIcon: Icon(Icons.priority_high_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: TipoDespacho.values.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.etiqueta),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            _tipoDespachoSeleccionado = valor;
                          });
                        },
                        validator: (valor) => valor == null
                            ? "Seleccione la urgencia del despacho."
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Sección para agregar tipos de sangre
                      const Text(
                        "Agregar unidades solicitadas",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.textoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: KeyedSubtree(
                              key: const Key("dropdown_tipo_sangre_solicitud"),
                              child: DropdownButtonFormField<TipoSangre>(
                                key: ValueKey(_resetDropdownTipoKey),
                                isExpanded: true,
                                initialValue: _tipoSangreSeleccionado,
                                decoration: const InputDecoration(
                                  labelText: "Grupo sanguíneo",
                                  prefixIcon: Icon(Icons.bloodtype_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: tiposDisponibles.map((tipo) {
                                  final disponible = stock[tipo] ?? 0;
                                  return DropdownMenuItem(
                                    value: tipo,
                                    child: Text(
                                      "${tipo.etiqueta} (Disp: $disponible)",
                                    ),
                                  );
                                }).toList(),
                                onChanged: tiposDisponibles.isEmpty
                                    ? null
                                    : (valor) {
                                        setState(() {
                                          _tipoSangreSeleccionado = valor;
                                        });
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              key: const Key("campo_cantidad_solicitud"),
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Cantidad",
                                hintText: "Ej: 2",
                                border: OutlineInputBorder(),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (valor) {
                                if ((valor == null || valor.trim().isEmpty) &&
                                    _unidadesSolicitadas.isNotEmpty) {
                                  return null;
                                }
                                return _validarCampoCantidad(valor);
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Botón Agregar tipo de sangre a la lista
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          key: const Key("boton_agregar_tipo"),
                          onPressed: _puedeAgregarLinea
                              ? _agregarTipoSangre
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text("Agregar a la solicitud"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColoresApp.primario,
                            side: BorderSide(
                              color: _puedeAgregarLinea
                                  ? ColoresApp.primario
                                  : ColoresApp.botonDeshabilitadoFondo,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Listado dinámico de tipos agregados
                      if (_unidadesSolicitadas.isEmpty)
                        Container(
                          key: const Key("lista_solicitud_vacia"),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ColoresApp.fondoPantalla,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColoresApp.botonDeshabilitadoFondo,
                            ),
                          ),
                          child: const Text(
                            "Aún no se han agregado tipos de sangre a la solicitud.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColoresApp.textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        Container(
                          key: const Key("lista_unidades_solicitadas"),
                          decoration: BoxDecoration(
                            color: ColoresApp.fondoPantalla,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColoresApp.botonDeshabilitadoFondo,
                            ),
                          ),
                          child: Column(
                            children: _unidadesSolicitadas.entries.map((entry) {
                              final tipo = entry.key;
                              final cantidad = entry.value;
                              final disponible = stock[tipo] ?? 0;

                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: ColoresApp.primario,
                                  foregroundColor:
                                      ColoresApp.textoSobrePrimario,
                                  child: Text(
                                    tipo.etiqueta,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "Cantidad solicitada: $cantidad unidades",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ColoresApp.textoPrincipal,
                                  ),
                                ),
                                subtitle: Text(
                                  "Stock disponible: $disponible",
                                  style: TextStyle(
                                    color: cantidad > disponible
                                        ? ColoresApp.error
                                        : ColoresApp.textoSecundario,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: IconButton(
                                  key: Key("boton_eliminar_${tipo.name}"),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: ColoresApp.error,
                                  ),
                                  tooltip: "Quitar",
                                  onPressed: () => _eliminarTipoSangre(tipo),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Botón Enviar Solicitud
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          key: const Key("boton_enviar_solicitud"),
                          onPressed: _formularioEsValido
                              ? _enviarSolicitud
                              : null,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text(
                            "Enviar Solicitud",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.primario,
                            foregroundColor: ColoresApp.textoSobrePrimario,
                            disabledBackgroundColor:
                                ColoresApp.botonDeshabilitadoFondo,
                            disabledForegroundColor:
                                ColoresApp.botonDeshabilitadoTexto,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}