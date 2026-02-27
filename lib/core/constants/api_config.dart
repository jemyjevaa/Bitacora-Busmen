class ApiConfig {
  // Dynamic API parameters (set after login)
  static String? _empresa;
  static int? _idUsuario;
  
  // Default fallback values
  static const String defaultEmpresa = 'lyondellbasell';
  static const int defaultIdUsuario = 11;
  static const String tipoRuta = 'EXT';
  static const String tipoUsuario = 'adm';
  
  /// Initialize constants with user data
  static void initialize({required String empresa, required int idUsuario}) {
    _empresa = empresa;
    _idUsuario = idUsuario;
  }

  /// Set the current company (should be called after login)
  static void setEmpresa(String empresa) {
    _empresa = empresa;
  }
  
  /// Set the current user ID (should be called after login)
  static void setIdUsuario(int idUsuario) {
    _idUsuario = idUsuario;
  }
  
  /// Get the current empresa (uses set value or default)
  static String get empresa => _empresa ?? defaultEmpresa;
  
  /// Get the current user ID (uses set value or default)
  static int get idUsuario => _idUsuario ?? defaultIdUsuario;
  
  /// Clear configuration (for logout)
  static void clear() {
    _empresa = null;
    _idUsuario = null;
  }
  
  /// Get the request body for fetching routes
  static Map<String, dynamic> getRouteRequestBody({DateTime? date}) {
    final Map<String, dynamic> body = {
      'empresa': empresa,
      'idUsuario': idUsuario,
      'tipo_ruta': tipoRuta,
      'tipo_usuario': tipoUsuario,
    };

    if (date != null) {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      body['fecha'] = '$year-$month-$day';
    }

    return body;
  }
}
