import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Realiza una petición POST al API
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? baseUrl,
    Map<String, String>? headers,
    bool isUrlEncoded = false,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConstants.baseUrl}$endpoint');
      
      final defaultHeaders = <String, String>{
        'Accept': 'application/json',
      };

      if (isUrlEncoded) {
        defaultHeaders['Content-Type'] = 'application/x-www-form-urlencoded';
      } else {
        defaultHeaders['Content-Type'] = 'application/json';
      }
      
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }

      final response = await _client.post(
        url,
        headers: defaultHeaders,
        body: isUrlEncoded 
            ? body.map((k, v) => MapEntry(k, v.toString())) 
            : jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Realiza una petición POST y devuelve la respuesta completa (body + headers)
  Future<http.Response> postWithHeaders({
    required String endpoint,
    required Map<String, dynamic> body,
    String? baseUrl,
    Map<String, String>? headers,
    bool isUrlEncoded = false,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConstants.baseUrl}$endpoint');
      
      final defaultHeaders = <String, String>{
        'Accept': 'application/json',
      };

      if (isUrlEncoded) {
        defaultHeaders['Content-Type'] = 'application/x-www-form-urlencoded';
      } else {
        defaultHeaders['Content-Type'] = 'application/json';
      }
      
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }

      final response = await _client.post(
        url,
        headers: defaultHeaders,
        body: isUrlEncoded 
            ? body.map((k, v) => MapEntry(k, v.toString())) 
            : jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Realiza una petición GET al API
  Future<dynamic> get({
    required String endpoint,
    String? baseUrl,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      var urlString = '${baseUrl ?? ApiConstants.baseUrl}$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final query = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
        urlString = '$urlString?$query';
      }
      final url = Uri.parse(urlString);
      
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }

      final response = await _client.get(
        url,
        headers: defaultHeaders,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  /// Realiza una petición PUT al API
  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
    String? baseUrl,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConstants.baseUrl}$endpoint');
      
      final defaultHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      
      final response = await _client.put(
        url,
        headers: defaultHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) return {'respuesta': true};
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }


  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}
