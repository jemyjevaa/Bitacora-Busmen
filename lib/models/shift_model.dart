class ShiftResponse {
  final bool respuesta;
  final List<ShiftModel> data;

  ShiftResponse({required this.respuesta, required this.data});

  factory ShiftResponse.fromJson(Map<String, dynamic> json) {
    return ShiftResponse(
      respuesta: json['respuesta'] == true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ShiftModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ShiftModel {
  final String turnoRuta;
  final String direccionRuta;

  ShiftModel({
    required this.turnoRuta,
    required this.direccionRuta,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      turnoRuta: (json['turno_ruta'] ?? '').toString(),
      direccionRuta: (json['direccion_ruta'] ?? '').toString(),
    );
  }

  bool get isEntrada => direccionRuta.toUpperCase() == 'ENTRADA';
  bool get isSalida => direccionRuta.toUpperCase() == 'SALIDA';
}
