import "package:flutter/material.dart";
import "package:proyecto_banco_sangre/logica/donacion.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/registro_donantes.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";

class PantallaRegistroDonaciones extends StatefulWidget {
  final RegistroDonacion registroDonacion;
  final RegistroDonantes registroDonantes;

  const PantallaRegistroDonaciones({
    super.key,
    required this.registroDonacion,
    required this.registroDonantes,
  });

  @override
  State<PantallaRegistroDonaciones> createState() =>
      _PantallaRegistroDonacionesState();
}

class _PantallaRegistroDonacionesState
    extends State<PantallaRegistroDonaciones> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _rutDonanteController = TextEditingController();
  final _fechaTomaController = TextEditingController();
  final _volumenDonadoController = TextEditingController();

  TipoSangre? _tipoSangre;
  DateTime? _fechaDeToma;
  Donante? _donanteEncontrado;

  @override
  void initState() {
    super.initState();
    // Inicializar por defecto con la fecha de hoy
    final hoy = DateTime.now();
    _fechaDeToma = DateTime(hoy.year, hoy.month, hoy.day);
    _fechaTomaController.text = _formatearFecha(_fechaDeToma!);
  }

  @override
  void dispose() {
    _rutDonanteController.dispose();
    _fechaTomaController.dispose();
    _volumenDonadoController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, "0");
    final mes = fecha.month.toString().padLeft(2, "0");
    return "$dia/$mes/${fecha.year}";
  }

  // Búsqueda reactiva del donante al escribir el RUT
  void _alCambiarRut(String valor) {
    Donante? encontrado;
    if (esRutValido(valor)) {
      encontrado = widget.registroDonantes.buscarPorRut(valor);
    }

    setState(() {
      _donanteEncontrado = encontrado;
      if (encontrado != null) {
        _tipoSangre = encontrado.tipoSangre;
      } else {
        _tipoSangre = null;
      }
    });
  }

  // Funciones de validación
  String? _validarCampoRutDonante(String? valor) {
    try {
      final rut = validarYNormalizarRut(valor ?? "");
      final donante = widget.registroDonantes.buscarPorRut(rut);

      if (donante == null) {
        return "No existe un donante registrado con este RUT.";
      }
      if (!donante.esApto) {
        return "El donante no está apto para donar (${donante.elegibilidad.etiqueta}).";
      }
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoFechaToma(String? _) {
    if (_fechaDeToma == null) {
      return "Seleccione una fecha de toma.";
    }
    try {
      validarFechaDeToma(_fechaDeToma!);
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoVolumen(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "El volumen donado no puede estar vacío.";
    }
    final volumenNum = int.tryParse(valor.trim());
    if (volumenNum == null) {
      return "Ingrese un valor numérico válido (ej: 450).";
    }
    try {
      validarVolumen(volumenNum);
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  bool get _formularioEsValido {
    return _validarCampoRutDonante(_rutDonanteController.text) == null &&
        _validarCampoFechaToma(null) == null &&
        _validarCampoVolumen(_volumenDonadoController.text) == null &&
        _tipoSangre != null;
  }

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

  // En caso de ser el formulario válido, guarda la donación en el map y limpia el formulario
  void _registrarDonacion() {
    if (!_formularioEsValido) return;

    final rutNormalizado = validarYNormalizarRut(_rutDonanteController.text);
    final volumenDonado = int.parse(
      _volumenDonadoController.text.trim().replaceAll(",", "."),
    );

    final idDonacion = widget.registroDonacion.ingresarDonacion(
      tipoSangre: _tipoSangre!,
      volumenDonado: volumenDonado,
      fechaDeToma: _fechaDeToma!,
      rutDonante: rutNormalizado,
    );

    _mostrarMensaje(
      "Donación registrada exitosamente (ID: $idDonacion)",
      color: ColoresApp.exito,
    );
    _limpiarFormulario();
  }

  // Selector de fecha de toma
  Future<void> _seleccionarFecha(BuildContext context) async {
    final hoy = DateTime.now();
    final fechaInicial = _fechaDeToma ?? hoy;

    final seleccion = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: hoy,
      helpText: "Seleccione fecha de toma",
    );

    if (seleccion != null) {
      setState(() {
        _fechaDeToma = seleccion;
        _fechaTomaController.text = _formatearFecha(seleccion);
      });
    }
  }

  void _limpiarFormulario() {
    final hoy = DateTime.now();
    _rutDonanteController.clear();
    _volumenDonadoController.clear();
    setState(() {
      _donanteEncontrado = null;
      _tipoSangre = null;
      _fechaDeToma = DateTime(hoy.year, hoy.month, hoy.day);
      _fechaTomaController.text = _formatearFecha(_fechaDeToma!);
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fechaCaducidadEstimada = _fechaDeToma != null
        ? Donacion.calcularFechaCaducidad(_fechaDeToma!)
        : null;

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
                      Row(
                        children: const [
                          Icon(
                            Icons.vaccines,
                            color: ColoresApp.primario,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Registro de Nueva Donación",
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
                        "Complete todos los datos requeridos para registrar la donación.",
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13.5,
                        ),
                      ),
                      const Divider(height: 32, thickness: 1),

                      // Campo RUT Donante
                      TextFormField(
                        key: const Key("campo_rut_donante"),
                        controller: _rutDonanteController,
                        decoration: const InputDecoration(
                          labelText: "RUT donante",
                          hintText: "Ej: 12345678-5",
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoRutDonante,
                        onChanged: _alCambiarRut,
                      ),

                      // Tarjeta informativa si se encuentra el donante
                      if (_donanteEncontrado != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          key: const Key("tarjeta_info_donante"),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _donanteEncontrado!.esApto
                                ? ColoresApp.exito.withValues(alpha: 0.1)
                                : ColoresApp.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _donanteEncontrado!.esApto
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color: _donanteEncontrado!.esApto
                                    ? ColoresApp.exito
                                    : ColoresApp.error,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Donante: ${_donanteEncontrado!.nombre} | Grupo: ${_donanteEncontrado!.tipoSangre.etiqueta}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ColoresApp.textoPrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Campo Fecha de toma
                      TextFormField(
                        key: const Key("campo_fecha_toma"),
                        controller: _fechaTomaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Fecha de toma",
                          hintText: "Seleccione en el calendario",
                          prefixIcon: Icon(Icons.view_kanban_outlined),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoFechaToma,
                        onTap: () => _seleccionarFecha(context),
                      ),
                      if (fechaCaducidadEstimada != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Fecha de caducidad calculada (+42 días): ${_formatearFecha(fechaCaducidadEstimada)}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Campos Tipo de Sangre y Volumen Donado
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TipoSangre>(
                              key: const Key("dropdown_tipo_sangre"),
                              isExpanded: true,
                              value: _tipoSangre,
                              decoration: const InputDecoration(
                                labelText: "Grupo sanguíneo",
                                prefixIcon: Icon(Icons.bloodtype_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: TipoSangre.values.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo.etiqueta),
                                );
                              }).toList(),
                              // Bloqueado para edición manual: se asigna automáticamente según el donante
                              onChanged: null,
                              validator: (valor) =>
                                  valor == null ? "Requerido" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              key: const Key("campo_volumen_donado"),
                              controller: _volumenDonadoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: "Volumen (ml)",
                                hintText: "Ej: 450",
                                prefixIcon: Icon(Icons.science),
                                border: OutlineInputBorder(),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validarCampoVolumen,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botón Registrar
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          key: const Key("boton_registrar"),
                          onPressed: _formularioEsValido
                              ? _registrarDonacion
                              : null,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            "Registrar Donación",
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