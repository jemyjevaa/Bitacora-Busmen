import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitacora_busmen/models/login_response.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  SharedPreferences? _prefs;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  // Inicializar SharedPreferences una sola vez (ejecutar al iniciar la app)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLogin => _prefs?.getBool('isLogin') ?? false;
  set isLogin(bool value) => _prefs?.setBool('isLogin', value);

  // region persist data user

  bool get isPersist => _prefs?.getBool('isPersist') ?? false;
  set isPersist(bool value) => _prefs?.setBool('isPersist', value);

  String? get email => _prefs?.getString('email');
  set email(String? value) => _prefs?.setString('email', value ?? '');

  String get formattedName {
    return getUserData()?.nombre ?? 'Usuario';
  }

  String? get token => _prefs?.getString('token');
  set token(String? value) => _prefs?.setString('token', value ?? '');

  String? get textQR => _prefs?.getString('textQR');
  set textQR(String? value) => _prefs?.setString('textQR', value ?? '');

  String get nameQR => _prefs?.getString('nameQR') ?? '';
  set nameQR(String value) => _prefs?.setString('nameQR', value);

  String? get lastCompanyClave => _prefs?.getString('lastCompanyClave');
  set lastCompanyClave(String? value) => _prefs?.setString('lastCompanyClave', value ?? '');

  int? get qrTimestamp => _prefs?.getInt('qrTimestamp');
  set qrTimestamp(int? value) => _prefs?.setInt('qrTimestamp', value ?? 0);

  bool isQRExpired() {
    if (qrTimestamp == null || qrTimestamp == 0) return true;
    final generationDate = DateTime.fromMillisecondsSinceEpoch(qrTimestamp!);
    final now = DateTime.now();
    final difference = now.difference(generationDate).inDays;
    return difference >= 15;
  }

  int getDaysRemaining() {
    if (qrTimestamp == null || qrTimestamp == 0) return 0;
    final generationDate = DateTime.fromMillisecondsSinceEpoch(qrTimestamp!);
    final expirationDate = generationDate.add(const Duration(days: 15));
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }


  // endregion persist data user

  // region Login Data

  Future<void> setUserData(Map<String, dynamic> userData) async {
    String jsonString = jsonEncode(userData);
    await _prefs?.setString('userData', jsonString);
  }

  Usuario? getUserData() {
    final jsonString = _prefs?.getString('userData');
    if (jsonString == null || jsonString.isEmpty) return null;

    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Usuario.fromJson(map);
  }

  Future<void> setCompanyData(Map<String, dynamic> companyData)async{
    String jsonString = jsonEncode(companyData);
    await _prefs?.setString('companyData', jsonString);
  }

  Empresa? getCompanyData() {
    final jsonString = _prefs?.getString('companyData');
    if (jsonString == null || jsonString.isEmpty) return null;

    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Empresa.fromJson(map);
  }


  // endregion Login Data


  // Check if panic button feature is enabled for current user's company
  bool isPanicButtonEnabled() {
    final user = getUserData();
    if (user == null) return false;
    
    final email = user.email.toLowerCase();
    
    // List of authorized email domains
    final authorizedDomains = [
      '@flexsur.com',
      'flexsur',
    ];
    
    return authorizedDomains.any((domain) => email.contains(domain));
  }

  // Limpiar datos
  Future<void> clear() async {
    _prefs?.remove("userData");
    _prefs?.remove("companyData");
    isLogin = false;
  }
}
