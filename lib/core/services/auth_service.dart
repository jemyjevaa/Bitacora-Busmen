import 'package:flutter/foundation.dart';
import 'package:bitacora_busmen/models/login_response.dart';
import 'package:bitacora_busmen/core/constants/api_constants.dart';
import 'package:bitacora_busmen/core/constants/api_config.dart';
import 'package:bitacora_busmen/core/services/api_service.dart';
import 'package:bitacora_busmen/core/services/user_session.dart';

class AuthService {
  final ApiService _apiService;
  
  AuthService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Login directo con el endpoint unificado
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Inciando login para $email...');
      
      final responseBody = await _apiService.post(
        endpoint: ApiConstants.validaUsuarioEmpresa,
        baseUrl: ApiConstants.baseUrl,
        body: {
          'correo': email,
          'contraseña': password,
        },
        isUrlEncoded: true,
      );

      debugPrint('AuthService: Login response received');
      
      final loginRes = ApiResLogin.fromJson(responseBody);
      
      if (!loginRes.respuesta) {
        throw AuthException('Credenciales incorrectas o usuario no válido');
      }

      final user = loginRes.usuario;
      final empresa = loginRes.empresa;

      // Initialize API Configuration with user data
      ApiConfig.initialize(
        empresa: empresa.clave ?? user.idempresa,
        idUsuario: int.tryParse(user.id) ?? ApiConfig.defaultIdUsuario,
      );

      final session = UserSession();
      await session.init();
      await session.setUserData(user.toJson());
      await session.setCompanyData(empresa.toJson());
      
      // Sync UserSession extra fields identified in reference
      session.isLogin = true;
      session.nameQR = user.nombre;
      session.lastCompanyClave = empresa.clave;
      session.qrTimestamp = DateTime.now().millisecondsSinceEpoch;

      debugPrint('AuthService: Login successful for ${user.nombre} at ${empresa.nombre}');
      
      return user;
    } catch (e) {
      debugPrint('AuthService Error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión o datos: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await UserSession().clear();
    ApiConfig.clear();
  }

  void dispose() => _apiService.dispose();
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
