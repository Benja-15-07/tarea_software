import "package:flutter/material.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donantes.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";

class PantallaRegistroDonantes extends StatefulWidget {
  final RegistroDonantes registroDonantes;

  const PantallaRegistroDonantes({
    super.key,
    required this.registroDonantes,
  });

  @override
  State<PantallaRegistroDonantes> createState() =>
      _PantallaRegistroDonantesState();
}

class _PantallaRegistroDonantesState extends State<PantallaRegistroDonantes> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _rutController = TextEditingController();
  final _nombreController = TextEditingController();
  final _fechaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _telefonoController = TextEditingController();

  DateTime? _fechaNacimiento;
  TipoSangre? _tipoSangreSeleccionado;
  EstadoElegibilidad? _elegibilidadSeleccionada;

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _fechaController.dispose();
    _pesoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // --- Funciones de Validación ---

  String? _validarCampoRut(String? valor) {
    try {
      validarYNormalizarRut(valor ?? "");
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoNombre(String? valor) {
    try {
      validarNombre(valor ?? "");
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoFecha(String? _) {
    if (_fechaNacimiento == null) {
      return "Seleccione una fecha de nacimiento.";
    }
    try {
      validarFechaNacimiento(_fechaNacimiento!);
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoPeso(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "El peso no puede estar vacío.";
    }
    final pesoNum = double.tryParse(valor.trim().replaceAll(",", "."));
    if (pesoNum == null) {
      return "Ingrese un valor numérico válido (ej: 70.5).";
    }
    try {
      validarPeso(pesoNum);
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  String? _validarCampoTelefono(String? valor) {
    try {
      validarYNormalizarTelefono(valor ?? "");
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  // --- Verificación para desactivar botón de registrar ---

  bool get _formularioEsValido {
    return _validarCampoRut(_rutController.text) == null &&
        _validarCampoNombre(_nombreController.text) == null &&
        _validarCampoFecha(null) == null &&
        _validarCampoPeso(_pesoController.text) == null &&
        _validarCampoTelefono(_telefonoController.text) == null &&
        _tipoSangreSeleccionado != null &&
        _elegibilidadSeleccionada != null;
  }

  // --- Selector de fecha nativo ---

  Future<void> _seleccionarFecha(BuildContext context) async {
    final hoy = DateTime.now();
    final fechaInicial =
        _fechaNacimiento ?? DateTime(hoy.year - 25, hoy.month, hoy.day);

    final seleccion = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: "Seleccione fecha de nacimiento",
    );

    if (seleccion != null) {
      setState(() {
        _fechaNacimiento = seleccion;
        final dia = seleccion.day.toString().padLeft(2, "0");
        final mes = seleccion.month.toString().padLeft(2, "0");
        _fechaController.text = "$dia/$mes/${seleccion.year}";
      });
    }
  }

  // --- Mostrar mensaje ---

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

  // --- Guardar donante y limpiar formulario ---

  void _registrarDonante() {
    if (!_formularioEsValido) return;

    final peso = double.parse(_pesoController.text.trim().replaceAll(",", "."));

    final nuevoDonante = Donante(
      rut: _rutController.text,
      nombre: _nombreController.text,
      fechaNacimiento: _fechaNacimiento!,
      tipoSangre: _tipoSangreSeleccionado!,
      peso: peso,
      telefono: _telefonoController.text,
      elegibilidad: _elegibilidadSeleccionada!,
    );

    final exito = widget.registroDonantes.ingresarDonante(nuevoDonante);

    if (exito) {
      _mostrarMensaje(
        "Donante registrado exitosamente.",
        color: ColoresApp.exito,
      );
      _limpiarFormulario();
    } else {
      _mostrarMensaje(
        "Error: Ya existe un donante registrado con ese RUT.",
        color: ColoresApp.error,
      );
    }
  }

  void _limpiarFormulario() {
    _rutController.clear();
    _nombreController.clear();
    _fechaController.clear();
    _pesoController.clear();
    _telefonoController.clear();

    setState(() {
      _fechaNacimiento = null;
      _tipoSangreSeleccionado = null;
      _elegibilidadSeleccionada = null;
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              color: ColoresApp.primario,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Registro de Nuevo Donante",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Complete todos los datos requeridos para registrar al donante.",
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13.5,
                        ),
                      ),
                      const Divider(height: 32, thickness: 1),

                      //Campo RUT
                      TextFormField(
                        key: const Key("campo_rut"),
                        controller: _rutController,
                        decoration: const InputDecoration(
                          labelText: "RUT",
                          hintText: "Ej: 12345678-5",
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoRut,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      //Campo Nombre
                      TextFormField(
                        key: const Key("campo_nombre"),
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: "Nombre completo",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoNombre,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      //Campo Fecha de Nacimiento
                      TextFormField(
                        key: const Key("campo_fecha"),
                        controller: _fechaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Fecha de nacimiento",
                          hintText: "Seleccione en el calendario",
                          prefixIcon: Icon(Icons.cake_outlined),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoFecha,
                        onTap: () => _seleccionarFecha(context),
                      ),
                      const SizedBox(height: 16),

                      //Campos Tipo de Sangre y Peso
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TipoSangre>(
                              key: const Key("dropdown_tipo_sangre"),
                              isExpanded: true,
                              initialValue: _tipoSangreSeleccionado,
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
                              onChanged: (valor) {
                                setState(() {
                                  _tipoSangreSeleccionado = valor;
                                });
                              },
                              validator: (valor) =>
                                  valor == null ? "Requerido" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              key: const Key("campo_peso"),
                              controller: _pesoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Peso (kg)",
                                hintText: "Ej: 75",
                                prefixIcon: Icon(Icons.monitor_weight_outlined),
                                border: OutlineInputBorder(),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validarCampoPeso,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      //Campo Teléfono
                      TextFormField(
                        key: const Key("campo_telefono"),
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Teléfono de contacto",
                          hintText: "Ej: +56912345678",
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoTelefono,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      //Campo Estado de Elegibilidad
                      DropdownButtonFormField<EstadoElegibilidad>(
                        key: const Key("dropdown_elegibilidad"),
                        isExpanded: true,
                        initialValue: _elegibilidadSeleccionada,
                        decoration: const InputDecoration(
                          labelText: "Estado de elegibilidad",
                          prefixIcon: Icon(Icons.fact_check_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: EstadoElegibilidad.values.map((estado) {
                          return DropdownMenuItem(
                            value: estado,
                            child: Text(estado.etiqueta),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            _elegibilidadSeleccionada = valor;
                          });
                        },
                        validator: (valor) => valor == null
                            ? "Seleccione un estado de elegibilidad."
                            : null,
                      ),
                      const SizedBox(height: 28),

                      //Botón Registrar
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          key: const Key("boton_registrar"),
                          onPressed:
                              _formularioEsValido ? _registrarDonante : null,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            "Registrar Donante",
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