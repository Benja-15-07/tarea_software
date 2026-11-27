import "package:flutter/material.dart";
import "package:proyecto_banco_sangre/logica/enums/rol.dart";
import "package:proyecto_banco_sangre/logica/registro_usuarios.dart";
import "package:proyecto_banco_sangre/vistas/estilo/colores_app.dart";

class PantallaInicioSesion extends StatefulWidget {
  final RegistroUsuarios registroUsuarios;

  const PantallaInicioSesion({
    super.key,
    required this.registroUsuarios,
  });

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  String? _validarCampoUsuario(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "El nombre de usuario no puede estar vacío.";
    }
    return null;
  }

  String? _validarCampoContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return "La contraseña no puede estar vacía.";
    }
    return null;
  }

  bool get _formularioEsValido {
    return _validarCampoUsuario(_usuarioController.text) == null &&
        _validarCampoContrasena(_contrasenaController.text) == null;
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

  void _iniciarSesion() {
    if (!_formularioEsValido) return;

    final rol = widget.registroUsuarios.validarCredenciales(
      _usuarioController.text,
      _contrasenaController.text,
    );

    if (rol == null) {
      _mostrarMensaje(
        "Credenciales inválidas. Verifique su usuario y contraseña.",
        color: ColoresApp.error,
      );
      return;
    }

    _mostrarMensaje(
      "Inicio de sesión exitoso. Rol: ${rol.etiqueta}",
      color: ColoresApp.exito,
    );
    // La redirección según rol se implementa en T04.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Iniciar Sesión"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
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
                      Row(
                        children: const [
                          Icon(
                            Icons.login,
                            color: ColoresApp.primario,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Inicio de Sesión",
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
                        "Ingrese sus credenciales para acceder al sistema.",
                        style: TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 13.5,
                        ),
                      ),
                      const Divider(height: 32, thickness: 1),

                      TextFormField(
                        key: const Key("campo_usuario"),
                        controller: _usuarioController,
                        decoration: const InputDecoration(
                          labelText: "Usuario",
                          hintText: "Ej: juan@banco.cl",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoUsuario,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        key: const Key("campo_contrasena"),
                        controller: _contrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validarCampoContrasena,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          key: const Key("boton_iniciar_sesion"),
                          onPressed: _formularioEsValido ? _iniciarSesion : null,
                          icon: const Icon(Icons.login),
                          label: const Text(
                            "Iniciar sesión",
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