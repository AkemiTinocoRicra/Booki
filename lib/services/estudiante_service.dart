import '../core/api_client.dart';
import '../models/estudiante.dart';
import 'session_service.dart';

class EstudianteService {
  final ApiClient _client;
  final SessionService _sessionService;

  EstudianteService({
    ApiClient? client,
    SessionService? sessionService,
  })  : _client = client ?? ApiClient(),
        _sessionService = sessionService ?? SessionService();

  Future<String> _token() async =>
      await _sessionService.readToken() ?? '';

  Future<List<Estudiante>> fetchAll({String? estado}) async {
    final path = estado == null
        ? '/api/estudiantes'
        : '/api/estudiantes?estado=$estado';
    final data = await _client.get(path, token: await _token());
    return (data as List)
        .map((e) => Estudiante.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Estudiante> fetchById(int id) async {
    final data = await _client.get('/api/estudiantes/$id', token: await _token());
    return Estudiante.fromJson(data as Map<String, dynamic>);
  }

  Future<Estudiante> create({
    required String dni,
    required String nombres,
    required String apellidos,
    String? fechaNacimiento,
    required String contrasena,
    required int idGrado,
  }) async {
    final data = await _client.post(
      '/api/estudiantes',
      token: await _token(),
      body: {
        'dni': dni,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'contrasena': contrasena,
        'id_grado': idGrado,
      },
    );
    return Estudiante.fromJson(data as Map<String, dynamic>);
  }

  Future<Estudiante> update(
    int id, {
    String? nombres,
    String? apellidos,
    String? fechaNacimiento,
    String? contrasena,
    int? idGrado,
    String? estado,
  }) async {
    final body = <String, dynamic>{};
    if (nombres != null) body['nombres'] = nombres;
    if (apellidos != null) body['apellidos'] = apellidos;
    if (fechaNacimiento != null) body['fecha_nacimiento'] = fechaNacimiento;
    if (contrasena != null && contrasena.isNotEmpty) {
      body['contrasena'] = contrasena;
    }
    if (idGrado != null) body['id_grado'] = idGrado;
    if (estado != null) body['estado'] = estado;

    final data = await _client.put(
      '/api/estudiantes/$id',
      token: await _token(),
      body: body,
    );
    return Estudiante.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _client.delete('/api/estudiantes/$id', token: await _token());
  }
}
