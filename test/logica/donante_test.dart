import "package:flutter_test/flutter_test.dart";
import "package:proyecto_banco_sangre/logica/donante.dart";
import "package:proyecto_banco_sangre/logica/enums/estado_elegibilidad.dart";
import "package:proyecto_banco_sangre/logica/enums/tipo_sangre.dart";

void main() {
  group("Pruebas unitarias de la clase Donante", () {
    late Donante donante;
    late Donante donante2;
    late Donante donante3;
    final fechaNacimiento = DateTime(1998, 5, 20);

    setUp(() {
      donante = Donante(
        rut: "12345678-9",
        nombre: "Juan Pérez",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.oPositivo,
        peso: 75,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );

      donante2 = Donante(
        rut: "12345678-9",//Mismo rut que donante
        nombre: "Juan Pérez Modificado", //Otros datos modificados
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.abPositivo,
        peso: 120,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );

      donante3 = Donante(
        rut: "98765432-1", //Rut diferente a donante y donante2
        nombre: "Juan Pérez",
        fechaNacimiento: fechaNacimiento,
        tipoSangre: TipoSangre.oPositivo,
        peso: 75,
        telefono: "+56912345678",
        elegibilidad: EstadoElegibilidad.apto,
      );

    });

    test("Crear instancia de Donante asigna correctamente sus atributos.", () {
      expect(donante.rut, "12345678-9");
      expect(donante.nombre, "Juan Pérez");
      expect(donante.fechaNacimiento, fechaNacimiento);
      expect(donante.tipoSangre, TipoSangre.oPositivo);
      expect(donante.peso, 75);
      expect(donante.telefono, "+56912345678");
      expect(donante.elegibilidad, EstadoElegibilidad.apto);
      expect(donante.esApto, isTrue);
    });

    test("Actualizar elegibilidad funciona excepto si el donante es no apto permanentemente.", (){
      //Se intenta actualizar cuando el donante no está en un estado definitivo.
      final resultado1 = donante.actualizarElegibilidad(EstadoElegibilidad.noAptoPermanentemente);
      expect(resultado1, isTrue);
      expect(donante.elegibilidad, EstadoElegibilidad.noAptoPermanentemente);

      //Se intenta actualizar cuando el estado es no apto permanentemente.
      final resultado2 = donante.actualizarElegibilidad(EstadoElegibilidad.apto);
      expect(resultado2, isFalse);
      expect(donante.elegibilidad, EstadoElegibilidad.noAptoPermanentemente); //Sigue en su estado anterior.
    });

    group("Pruebas de igualdad y hashCode", () {
      test("Dos donantes con el mismo RUT se consideran iguales.", () {
        expect(donante, equals(donante2));
        expect(donante.hashCode, equals(donante2.hashCode));        
      });

      test("Dos donantes con Rut diferente no se consideran iguales, aún cuando tienen otros datos iguales.", () {
        expect(donante, isNot(equals(donante3)));
        expect(donante.hashCode, isNot(equals(donante3.hashCode)));
      });
    });
  });
}