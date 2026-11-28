import "package:proyecto_banco_sangre/logica/enums/rol.dart";

//Clase que representa a un usuario del sistema
class Usuario {
  final String usuario;
  final String contrasena;
  final Rol rol;

  Usuario({
    required String usuario,
    required String contrasena,
    required this.rol,
  }) : usuario = validarUsuario(usuario),
       contrasena = validarContrasena(contrasena);

  //Se sobrescribe el operador == para comparar usuarios por su nombre de usuario
  @override
  bool operator == (Object other) => identical(this, other) || other is Usuario && runtimeType == other.runtimeType && usuario == other.usuario;

  //Al hacer que el hashcode sea el correspondiente al del string
  //$usuario permite que el sistema diferencie a las distintas instancias
  @override
  int get hashCode => usuario.hashCode;

  //Representación en String del usuario
  @override
  String toString() {
    return "Usuario: $usuario, Rol: ${rol.etiqueta}";
  }
}

//Valida que el nombre de usuario no esté vacío.
String validarUsuario(String usuario) {
  if (usuario.trim().isEmpty) {
    throw ArgumentError("El nombre de usuario no puede estar vacio.");
  }
  return usuario.trim();
}

//Valida que la contraseña no esté vacía.
String validarContrasena(String contrasena) {
  if (contrasena.isEmpty) {
    throw ArgumentError("La contraseña no puede estar vacia.");
  }
  return contrasena;
}
