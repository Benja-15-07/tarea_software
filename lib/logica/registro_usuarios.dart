import "package:proyecto_banco_sangre/logica/usuario.dart";
import "package:proyecto_banco_sangre/logica/enums/rol.dart";

class RegistroUsuarios {
  //Mapa nombre de usuario - Usuario
  final Map<String, Usuario> _usuarios = {};

  //Retorna una lista inmodificable
  List<Usuario> get usuarios => List.unmodifiable(_usuarios.values);

  //Entrega la cantidad de usuarios registrados
  int get cantidadUsuarios => _usuarios.length;

  //Ingresa un usuario y retorna false si el nombre de usuario ya existe
  bool ingresarUsuario(Usuario usuario) {
    if (_usuarios.containsKey(usuario.usuario)) {
      return false;
    }
    _usuarios[usuario.usuario] = usuario;
    return true;
  }

  //Busca un usuario por nombre, retorna null si no existe
  Usuario? buscarPorNombre(String usuario) {
    return _usuarios[usuario.trim()];
  }

  //Verifica si un nombre de usuario ya existe en el sistema
  bool existeUsuario(String usuario) {
    return _usuarios.containsKey(usuario.trim());
  }

  //Valida credenciales y retorna el rol asociado, o null si son inválidas
  Rol? validarCredenciales(String usuario, String contrasena) {
    final encontrado = _usuarios[usuario.trim()];
    if (encontrado == null) {
      return null;
    }
    if (encontrado.contrasena != contrasena) {
      return null;
    }
    return encontrado.rol;
  }
}