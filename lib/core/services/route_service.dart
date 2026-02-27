import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bitacora_busmen/core/constants/api_constants.dart';
import 'package:bitacora_busmen/core/constants/api_config.dart';
import 'package:bitacora_busmen/core/services/api_service.dart';
import 'package:bitacora_busmen/models/route_monitoring_model.dart';
import 'package:bitacora_busmen/models/shift_model.dart';

class RouteService {
  final ApiService _apiService;
  
  RouteService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Obtener todas las rutas asignadas al usuario
  Future<List<RouteMonitoringModel>> fetchRoutes({DateTime? date}) async {
    try {
      final response = await _apiService.post(
        endpoint: ApiConstants.unidadAsignadaRuta,
        body: ApiConfig.getRouteRequestBody(date: date),
        isUrlEncoded: true,
      );

      final routeRes = RouteResponse.fromJson(response);
      return routeRes.data;
    } catch (e) {
      debugPrint('RouteService Error: fetchRoutes failed: $e');
      throw Exception('Error al cargar rutas: ${e.toString()}');
    }
  }

  /// Obtener las paradas de una ruta específica
  Future<List<RouteStopModel>> fetchRouteStops(String claveRuta) async {
    try {
      final response = await _apiService.post(
        endpoint: ApiConstants.paradasRuta,
        body: {
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        },
        isUrlEncoded: true,
      );

      final stopRes = RouteStopResponse.fromJson(response);
      return stopRes.data;
    } catch (e) {
      debugPrint('RouteService Warning: fetchRouteStops failed for $claveRuta: $e');
      return [];
    }
  }

  /// Obtener los turnos de una empresa
  Future<List<ShiftModel>> fetchShifts(String empresa) async {
    try {
      final response = await _apiService.get(
        endpoint: '${ApiConstants.turnos}/$empresa/turnos',
      );

      final shiftRes = ShiftResponse.fromJson(response);
      return shiftRes.data;
    } catch (e) {
      debugPrint('RouteService Error: fetchShifts failed for $empresa: $e');
      return [];
    }
  }

  /// Tracking: Obtener detalles del dispositivo (Traccar API)
  Future<Map<String, dynamic>?> fetchDevice(int idPlataformaGps) async {
    try {
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.trackingUser}:${ApiConstants.trackingPass}'))}';
      
      final response = await _apiService.get(
        endpoint: '${ApiConstants.devices}?id=$idPlataformaGps',
        baseUrl: ApiConstants.baseUrlTracking,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      );
      
      if (response is List && response.isNotEmpty) {
         return response.first as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        return response;
      }
    } catch (e) {
      debugPrint('RouteService Error: fetchDevice $idPlataformaGps failed: $e');
    }
    return null;
  }

  /// Tracking: Obtener posición del dispositivo (Traccar API)
  Future<Map<String, dynamic>?> fetchPosition(int positionId) async {
    try {
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.trackingUser}:${ApiConstants.trackingPass}'))}';
      
      final response = await _apiService.get(
        endpoint: '${ApiConstants.positions}?id=$positionId',
        baseUrl: ApiConstants.baseUrlTracking,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      );
      
      if (response is List && response.isNotEmpty) {
         return response.first as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        return response;
      }
    } catch (e) {
      debugPrint('RouteService Error: fetchPosition $positionId failed: $e');
    }
    return null;
  }

  void dispose() => _apiService.dispose();
}
