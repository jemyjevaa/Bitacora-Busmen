class RouteResponse {
  final bool respuesta;
  final List<RouteMonitoringModel> data;

  RouteResponse({required this.respuesta, required this.data});

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      respuesta: json['respuesta'] == true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => RouteMonitoringModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RouteMonitoringModel {
  final int? _id;
  final String? _ruta;
  final String? _unidad;
  final String? _claveRuta;
  
  // Dynamic fields for the form
  String poblacion;
  String arriboPlanta;

  // Safe Getters
  int get id => _id ?? 0;
  String get ruta => _ruta ?? 'Sin nombre';
  String get unidad => _unidad ?? 'Sin asignar';
  String get claveRuta => _claveRuta ?? '';

  RouteMonitoringModel({
    int? id,
    String? ruta,
    String? unidad,
    String? claveRuta,
    this.poblacion = '',
    this.arriboPlanta = '',
  }) : _id = id,
       _ruta = ruta,
       _unidad = unidad,
       _claveRuta = claveRuta;

  factory RouteMonitoringModel.fromJson(Map<String, dynamic> json) {
    return RouteMonitoringModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ruta: (json['nombre_ruta'] ?? json['ruta'] ?? 'Sin nombre').toString(),
      unidad: (json['unidad'] ?? json['clave_ruta'] ?? json['claveRuta'] ?? 'Sin asignar').toString(),
      claveRuta: (json['clave_ruta'] ?? json['claveRuta'] ?? '').toString(),
    );
  }
}

class RouteStopResponse {
  final bool respuesta;
  final List<RouteStopModel> data;

  RouteStopResponse({required this.respuesta, required this.data});

  factory RouteStopResponse.fromJson(Map<String, dynamic> json) {
    return RouteStopResponse(
      respuesta: json['respuesta'] == true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => RouteStopModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RouteStopModel {
  final int? _id;
  final String? _nombre;
  final double? _latitud;
  final double? _longitud;
  final int? _orden;

  int get id => _id ?? 0;
  String get nombre => _nombre ?? 'Sin nombre';
  double get latitud => _latitud ?? 0.0;
  double get longitud => _longitud ?? 0.0;
  int get orden => _orden ?? 0;

  RouteStopModel({
    int? id,
    String? nombre,
    double? latitud,
    double? longitud,
    int? orden,
  }) : _id = id,
       _nombre = nombre,
       _latitud = latitud,
       _longitud = longitud,
       _orden = orden;

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: (json['nombre'] ?? json['parada'] ?? 'Sin nombre').toString(),
      latitud: double.tryParse(json['latitud']?.toString() ?? '0') ?? 0.0,
      longitud: double.tryParse(json['longitud']?.toString() ?? '0') ?? 0.0,
      orden: int.tryParse(json['orden']?.toString() ?? '0') ?? 0,
    );
  }
}
