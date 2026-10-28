import 'package:flutter_application_01/core/errors.dart';
import 'package:flutter_application_01/models/estudiante.dart';
import 'package:flutter_application_01/services/estudiante_service.dart';
import 'package:flutter_application_01/viewmodels/estudiantes_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEstudianteService implements EstudianteService {
  _FakeEstudianteService({this.lista = const [], this.error, this.errorDelete, this.borrados});

  List<Estudiante> lista;
  ApiException? error;
  ApiException? errorDelete;
  List<int>? borrados;

  @override
  Future<List<Estudiante>> fetchAll({String? estado}) {
    final err = error;
    if (err != null) return Future.error(err);
    return Future.value(lista);
  }

  @override
  Future<void> delete(int id) async {
    final err = errorDelete;
    if (err != null) throw err;
    borrados?.add(id);
  }

  @override
  Future<Estudiante> fetchById(int id) => throw UnimplementedError();

  @override
  Future<Estudiante> create({
    required String dni,
    required String nombres,
    required String apellidos,
    String? fechaNacimiento,
    required String contrasena,
    required int idGrado,
  }) =>
      throw UnimplementedError();

  @override
  Future<Estudiante> update(
    int id, {
    String? nombres,
    String? apellidos,
    String? fechaNacimiento,
    String? contrasena,
    int? idGrado,
    String? estado,
  }) =>
      throw UnimplementedError();
}

const _ana = Estudiante(
  idEstudiante: 1,
  dni: '12345678',
  nombres: 'Ana',
  apellidos: 'Perez',
  idGrado: 3,
  estado: 'AC',
  cantidadCopas: 0,
);

void main() {
  test('load pasa loading → success con el service mockeado', () async {
    final vm = EstudiantesViewModel(
      service: _FakeEstudianteService(lista: const [_ana]),
    );

    final estados = <UiState>[];
    vm.addListener(() => estados.add(vm.uiState));

    await vm.load();

    expect(estados, [UiState.loading, UiState.success]);
    expect(vm.items, hasLength(1));
    expect(vm.items.first.dni, '12345678');
  });

  test('load con error → uiState=error y errorMessage', () async {
    final vm = EstudiantesViewModel(
      service: _FakeEstudianteService(
        error: const ApiException(401, 'Token inválido o expirado'),
      ),
    );

    await vm.load();

    expect(vm.uiState, UiState.error);
    expect(vm.errorMessage, 'Token inválido o expirado');
    expect(vm.items, isEmpty);
  });

  test('eliminar quita al estudiante de la lista y confirma', () async {
    final service = _FakeEstudianteService(lista: const [_ana], borrados: []);
    final vm = EstudiantesViewModel(service: service);
    await vm.load();

    final exito = await vm.eliminar(_ana);

    expect(exito, isTrue);
    expect(service.borrados, [1]);
    expect(vm.items, isEmpty);
    expect(vm.mensajeExito, 'Ana Perez quedó inactivo');
  });

  test('eliminar con error del service devuelve false', () async {
    final service = _FakeEstudianteService(
      lista: const [_ana],
      errorDelete: const ApiException(404, 'Estudiante no encontrado'),
    );
    final vm = EstudiantesViewModel(service: service);
    await vm.load();

    final exito = await vm.eliminar(_ana);

    expect(exito, isFalse);
    expect(vm.errorMessage, 'Estudiante no encontrado');
  });
}
