import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../screens/Businessman/owner_home_screen.dart';
//import '../screens/users/user_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


// easybook_app.dart
class EasyBookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyBook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // Ruta inicial que manejará el login
      routes: {
        '/': (context) => LoginScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => FutureBuilder<Map<String, dynamic>>(
            future: checkUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();  // Cargando...
              }

              if (snapshot.hasData) {
                final role = snapshot.data?['role'];
                if (role == 'owner') {
                  return OwnerHomeScreen();
                } else if (role == 'user') {
                 // return UserHomeScreen();
                }
              }

              return LoginScreen();  // Si no hay datos o el usuario no está logueado, vuelve al login
            },
          ),
        );
      },
    );
  }

  // Verifica el rol del usuario guardado en SharedPreferences
  Future<Map<String, dynamic>> checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ownerId = prefs.getString('ownerId');

    if (token != null && ownerId != null) {
      // Llama al API o usa la lógica necesaria para obtener el rol
      // Aquí simplemente retornamos un rol de ejemplo, deberías llamarlo desde tu API
      return {'role': 'owner'};  // Asumiendo que el rol del usuario es 'owner', cámbialo según corresponda.
    }

    return {'role': 'guest'};  // Si no hay token o ownerId, asume que el usuario es un invitado
  }
}