import 'package:flutter/material.dart';
import 'package:bitacora_busmen/views/login_screen.dart';
import 'package:bitacora_busmen/views/route_monitoring_screen.dart';
import 'package:bitacora_busmen/core/services/user_session.dart';
import 'package:bitacora_busmen/core/constants/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final session = UserSession();
  await session.init();
  
  if (session.isLogin) {
    final user = session.getUserData();
    if (user != null) {
      ApiConfig.initialize(
        empresa: user.idempresa,
        idUsuario: int.tryParse(user.id) ?? ApiConfig.defaultIdUsuario,
      );
    }
  }

  runApp(MyApp(initialRoute: session.isLogin ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busmen Bitácora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF1976D2),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const RouteMonitoringScreen(),
      },
    );
  }
}
