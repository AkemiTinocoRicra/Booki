import 'dart:convert';

import 'package:http/http.dart' as http;

import 'env.dart';
import 'errors.dart';

class ApiClient {
  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Uri _uri(String path) => Uri.parse('${Env.apiBaseUrl}$path');

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {String? token}) =>
      _send(() => _http.get(_uri(path), headers: _headers(token: token)));

  Future<dynamic> post(String path, {Object? body, String? token}) => _send(
        () => _http.post(
          _uri(path),
          headers: _headers(token: token),
          body: jsonEncode(body),
        ),
      );

  Future<dynamic> put(String path, {Object? body, String? token}) => _send(
        () => _http.put(
          _uri(path),
          headers: _headers(token: token),
          body: jsonEncode(body),
        ),
      );

  Future<dynamic> delete(String path, {String? token}) => _send(
        () => _http.delete(_uri(path), headers: _headers(token: token)),
      );

  Future<dynamic> _send(Future<http.Response> Function() operacion) async {
    final http.Response respuesta;
    try {
      respuesta = await operacion().timeout(Duration(milliseconds: Env.apiTimeout));
    } on Exception {
      throw const ApiException(0, 'Sin conexión con el servidor');
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      if (respuesta.body.isEmpty) return null;
      return jsonDecode(respuesta.body);
    }

    String mensaje = 'Error del servidor (${respuesta.statusCode})';
    try {
      final cuerpo = jsonDecode(respuesta.body);
      if (cuerpo is Map && cuerpo['detail'] is String) {
        mensaje = cuerpo['detail'] as String;
      }
    } on FormatException {
      // cuerpo no JSON: se mantiene el mensaje genérico
    }
    throw ApiException(respuesta.statusCode, mensaje);
  }
}
