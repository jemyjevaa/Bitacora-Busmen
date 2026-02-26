class ApiResLogin {
  final bool respuesta;
  final Usuario usuario;
  final Empresa empresa;

  ApiResLogin({
    required this.respuesta,
    required this.usuario,
    required this.empresa,
  });

  factory ApiResLogin.fromJson(Map<String, dynamic> json) {
    return ApiResLogin(
      respuesta: json['respuesta'] == true,
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      empresa: Empresa.fromJson(json['empresa'] as Map<String, dynamic>),
    );
  }
}

class ValidateDomainResponse {
  final String respuesta;
  final List<DomainData> datos;

  ValidateDomainResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateDomainResponse.fromJson(Map<String, dynamic> json) {
    return ValidateDomainResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => DomainData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DomainData {
  final String id;
  final String nombre;

  DomainData({
    required this.id,
    required this.nombre,
  });

  factory DomainData.fromJson(Map<String, dynamic> json) {
    return DomainData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class ValidateCompanyResponse {
  final String respuesta;
  final List<CompanyData> datos;

  ValidateCompanyResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateCompanyResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCompanyResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => CompanyData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CompanyData {
  final String id;
  final String nombre;
  final String? logo;

  CompanyData({
    required this.id,
    required this.nombre,
    this.logo,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'logo': logo,
    };
  }
}

class ValidateUserResponse {
  final String respuesta;
  final List<UserData> datos;

  ValidateUserResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateUserResponse.fromJson(Map<String, dynamic> json) {
    return ValidateUserResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => UserData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isSuccess => respuesta.isNotEmpty && datos.isNotEmpty;
}

class UserData {
  final String id;
  final String nombre;
  final String email;
  final String idEmpresa;
  final String? telefono;

  UserData({
    required this.id,
    required this.nombre,
    required this.email,
    required this.idEmpresa,
    this.telefono,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      idEmpresa: json['idempresa']?.toString() ?? json['idEmpresa']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'idempresa': idEmpresa,
      'telefono': telefono,
    };
  }
}

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String idempresa;
  final String? telefono;
  final String? avatar;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.idempresa,
    this.telefono,
    this.avatar,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] ?? json['idusuario'] ?? '').toString(),
      nombre: (json['nombre'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? json['correo'] ?? '').toString(),
      idempresa: (json['idempresa'] ?? json['empresa'] ?? '').toString(),
      telefono: json['telefono']?.toString(),
      avatar: (json['avatar'] ?? json['foto'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'idempresa': idempresa,
      'telefono': telefono,
      'avatar': avatar,
    };
  }
}

class Empresa {
  final String id;
  final String nombre;
  final String? clave;

  Empresa({required this.id, required this.nombre, this.clave});

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      clave: json['clave']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'clave': clave,
    };
  }
}
