class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String empresa;
  final String? telefono;
  final String? avatar;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.empresa,
    this.telefono,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      empresa: json['empresa']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'empresa': empresa,
      'telefono': telefono,
      'avatar': avatar,
    };
  }
}
