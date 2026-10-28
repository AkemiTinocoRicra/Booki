import 'package:flutter_application_01/models/estudiante.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const jsonEstudiante = {
    'id_estudiante': 7,
    'dni': '12345678',
    'nombres': 'Ana',
    'apellidos': 'Perez',
    'fecha_nacimiento': '2010-05-15',
    'id_grado': 3,
    'estado': 'AC',
    'cantidad_copas': 0,
  };

  test('Estudiante.fromJson parsea el payload del backend', () {
    final e = Estudiante.fromJson(jsonEstudiante);

    expect(e.idEstudiante, 7);
    expect(e.dni, '12345678');
    expect(e.nombres, 'Ana');
    expect(e.apellidos, 'Perez');
    expect(e.fechaNacimiento, '2010-05-15');
    expect(e.idGrado, 3);
    expect(e.estado, 'AC');
    expect(e.cantidadCopas, 0);
    expect(e.activo, isTrue);
    expect(e.nombreCompleto, 'Ana Perez');
  });

  test('Estudiante.fromJson tolera cantidad_copas ausente', () {
    final e = Estudiante.fromJson({...jsonEstudiante}..remove('cantidad_copas'));
    expect(e.cantidadCopas, 0);
  });

  test('Estudiante.toJson devuelve las claves del backend', () {
    final e = Estudiante.fromJson(jsonEstudiante);
    expect(e.toJson(), jsonEstudiante);
  });

  test('activo refleja el estado IN', () {
    final e = Estudiante.fromJson({...jsonEstudiante, 'estado': 'IN'});
    expect(e.activo, isFalse);
  });
}
