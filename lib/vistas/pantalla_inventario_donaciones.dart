import 'package:flutter/material.dart';
import 'package:proyecto_banco_sangre/logica/donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/estado_donacion.dart'; 
import 'package:proyecto_banco_sangre/logica/registro_donacion.dart';
import 'package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart';
import 'package:proyecto_banco_sangre/vistas/estilo/colores_app.dart';
import 'package:proyecto_banco_sangre/vistas/pantalla_detalle_donacion.dart';

class PantallaInventarioDonaciones extends StatefulWidget {
  final RegistroDonacion registroDonacion;
  

  const PantallaInventarioDonaciones({
    super.key,
    required this.registroDonacion,
  });

  @override
  State<PantallaInventarioDonaciones> createState() =>
      _PantallaInventarioDonacionesState();
}

class _PantallaInventarioDonacionesState extends State<PantallaInventarioDonaciones> {
  bool _retiroEnProgreso = false;

  @override
  Widget build(BuildContext context) {
    //obtenemos los calculos y datos agrupados
    final stockPorTipo = widget.registroDonacion.calcularStockPorTipo();
    final stockAgrupado = widget.registroDonacion.obtenerStockAgrupadoYOrdenado();
    
    //verificamos el total de unidades registradas
    final totalUnidades = stockPorTipo.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      appBar: AppBar(
        title: const Text("Inventario de Banco de Sangre"),
        centerTitle: true,
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: totalUnidades == 0
            ? _construirInventarioVacio()
            : _construirListaInventario(stockAgrupado, stockPorTipo),
      ),
    );
  }

  //inventario vacio:
  Widget _construirInventarioVacio() {
    return Center(
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
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.bloodtype_outlined,
                  size: 64,
                  color: ColoresApp.textoSecundario,
                ),
                SizedBox(height: 16),
                Text(
                  "No hay unidades disponibles",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoPrincipal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Actualmente el sistema no registra unidades de sangre disponibles en el inventario.",
                  style: TextStyle(
                    fontSize: 14,
                    color: ColoresApp.textoSecundario,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //inventario no vacio:
  Widget _construirListaInventario(
    Map<TipoSangre, List<Donacion>> stockAgrupado,
    Map<TipoSangre, int> stockPorTipo,
  ) {
    return ListView(
      children: TipoSangre.values.map((tipo) {
        final unidades = stockAgrupado[tipo] ?? [];
        final cantidadDisponible = stockPorTipo[tipo] ?? 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          color: ColoresApp.superficieTarjeta,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: ColoresApp.primario,
              foregroundColor: ColoresApp.textoSobrePrimario,
              child: Text(
                tipo.etiqueta,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            title: Text(
              "Grupo Sanguíneo: ${tipo.etiqueta}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoPrincipal,
              ),
            ),
            subtitle: Text(
              "Disponibles: $cantidadDisponible unidades",
              style: const TextStyle(
                color: ColoresApp.textoSecundario,
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              const Divider(height: 1, thickness: 1),
              if (unidades.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Sin stock disponible para este grupo.",
                    style: TextStyle(color: ColoresApp.textoSecundario),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: unidades.length,
                  itemBuilder: (context, index) {
                    final donacion = unidades[index];
                    final fechaTomaStr =
                        "${donacion.fechaDeToma.day.toString().padLeft(2, '0')}/${donacion.fechaDeToma.month.toString().padLeft(2, '0')}/${donacion.fechaDeToma.year}";
                    final fechaCadStr =
                        "${donacion.fechaDeCaducidad.day.toString().padLeft(2, '0')}/${donacion.fechaDeCaducidad.month.toString().padLeft(2, '0')}/${donacion.fechaDeCaducidad.year}";

                    return ListTile(
                      dense: true,
                      title: Text(
                        "ID: ${donacion.id}  |  Volumen: ${donacion.volumenDonado} ml",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Toma: $fechaTomaStr  •  Caduca: $fechaCadStr",
                        style: const TextStyle(color: ColoresApp.textoSecundario),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              donacion.estaExpirada()
                                  ? "VENCIDA"
                                  : donacion.estadoDonacion.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColoresApp.textoSobrePrimario,
                              ),
                            ),
                            backgroundColor: donacion.estaExpirada()
                                ? ColoresApp.error
                                : ColoresApp.exito,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            key: Key("boton_desechar_${donacion.id}"),
                            onPressed: (donacion.estaExpirada() &&
                                    donacion.estadoDonacion == EstadoDonacion.disponible &&
                                    !_retiroEnProgreso)
                                ? () => _ejecutarDesecho(donacion.id)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColoresApp.primario,
                              foregroundColor: ColoresApp.textoSobrePrimario,
                              disabledBackgroundColor: ColoresApp.botonDeshabilitadoFondo,
                              disabledForegroundColor: ColoresApp.botonDeshabilitadoTexto,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text(
                              "Desechar",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        final donacionActual = widget.registroDonacion.buscarPorId(donacion.id);

                        if(donacionActual == null || donacionActual.estadoDonacion != EstadoDonacion.disponible){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("La donación seleccionada no se encuentra disponible") ,
                            ),  
                          );
                          return;
                        }

                        showDialog<void>(
                          context: context, 
                          builder: (_) => PantallaDetalleDonacion(
                            donacion: donacionActual,
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  //Ejecuta el retiro y refresca la vista
  Future<void> _ejecutarDesecho(String id) async {
    setState(() {
      _retiroEnProgreso = true;
    });

    await Future<void>.delayed(Duration.zero);

    final resultado = widget.registroDonacion.retirarDonacionVencida(id);

    if (!mounted) return;

    setState(() {
      _retiroEnProgreso = false;
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: resultado.fueExitoso ? ColoresApp.exito : ColoresApp.error,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}