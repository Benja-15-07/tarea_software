enum Rol {
  receptorDonaciones,
  gestorInventario,
  funcionarioHospital,
}

extension RolExtension on Rol {
  String get etiqueta {
    switch (this) {
      case Rol.receptorDonaciones:
        return 'Receptor de Donaciones';
      case Rol.gestorInventario:
        return 'Gestor de Inventario';
      case Rol.funcionarioHospital:
        return 'Funcionario de Hospital';
    }
  }
}