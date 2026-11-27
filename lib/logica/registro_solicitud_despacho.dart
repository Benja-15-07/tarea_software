import "dart:math";
import "package:proyecto_banco_sangre/logica/enums/estado_solicitud.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_despacho.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";
import "package:proyecto_banco_sangre/logica/registro_donacion.dart";
import "package:proyecto_banco_sangre/logica/solicitud_despacho.dart";

class RegistroSolicitudDespacho {
  // Referencia al registro de donaciones para validar stock disponible
  final RegistroDonacion _registroDonacion;

  // Mapa de solicitudes que usa el id como clave
  final Map<String, SolicitudDespacho> _solicitudes = {};

  // Función encargada de generar los IDs únicos
  final String Function() _generarId;

  // Constructor: recibe el registro de donaciones y opcionalmente un generador de IDs
  RegistroSolicitudDespacho({
    required RegistroDonacion registroDonacion,
    String Function()? generarId,
  }) : _registroDonacion = registroDonacion,
       _generarId = generarId ?? _generarIdAleatorio;

  // Retorna una lista inmodificable con todas las solicitudes registradas
  List<SolicitudDespacho> get solicitudes =>
      List.unmodifiable(_solicitudes.values);

  // Entrega la cantidad total de solicitudes registradas
  int get cantidadSolicitudes => _solicitudes.length;

  // Retorna el stock actual disponible por tipo de sangre
  Map<TipoSangre, int> obtenerStockDisponible() {
    return _registroDonacion.calcularStockPorTipo();
  }

  // Verifica si existe al menos una donación disponible en el banco de sangre
  bool get hayDonacionesDisponibles {
    final stock = obtenerStockDisponible();
    return stock.values.any((cantidad) => cantidad > 0);
  }

  // Crea una instancia de SolicitudDespacho validando stock disponible,
  // la almacena en el mapa y retorna el ID generado.
  // Lanza ArgumentError si no hay donaciones o el stock es insuficiente.
  String ingresarSolicitud({
    required Map<TipoSangre, int> unidadesSolicitadas,
    required TipoDespacho tipoDespacho,
    DateTime? fechaSolicitud,
  }) {
    final stockDisponible = obtenerStockDisponible();
    final totalDisponible = stockDisponible.values.fold<int>(
      0,
      (suma, cantidad) => suma + cantidad,
    );

    if (totalDisponible == 0) {
      throw ArgumentError(
        "No existen donaciones disponibles en el inventario para realizar una solicitud.",
      );
    }

    String id;
    do {
      id = _generarId();
    } while (_solicitudes.containsKey(id));

    // La clase SolicitudDespacho valida obligatoriedad y stock por cada tipo
    final solicitud = SolicitudDespacho(
      id: id,
      unidadesSolicitadas: unidadesSolicitadas,
      tipoDespacho: tipoDespacho,
      stockDisponible: stockDisponible,
      fechaSolicitud: fechaSolicitud,
    );

    _solicitudes[id] = solicitud;
    return id;
  }

  // Busca una solicitud por su ID, retorna null si no existe
  SolicitudDespacho? buscarPorId(String id) {
    return _solicitudes[id];
  }

  // Verifica si existe una solicitud con el ID dado
  bool existeSolicitud(String id) {
    return _solicitudes.containsKey(id);
  }

  // Actualiza el estado de una solicitud registrada dado su ID
  bool actualizarEstadoSolicitud(String id, EstadoSolicitud nuevoEstado) {
    final solicitud = _solicitudes[id];
    if (solicitud == null) {
      return false;
    }
    return solicitud.actualizarEstado(nuevoEstado);
  }

  // Retorna las solicitudes en estado pendiente ordenadas por fecha ascendente
  List<SolicitudDespacho> getSolicitudesPendientesOrdenadasPorFecha() {
    final pendientes = _solicitudes.values
        .where((s) => s.estadoSolicitud == EstadoSolicitud.pendiente)
        .toList();
    pendientes.sort((a, b) => a.fechaSolicitud.compareTo(b.fechaSolicitud));
    return pendientes;
  }

  // Genera un número de 7 dígitos entre 1000000 y 9999999 como String
  static String _generarIdAleatorio() {
    final random = Random();
    final numero = 1000000 + random.nextInt(9000000);
    return numero.toString();
  }
}