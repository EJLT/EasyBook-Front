import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../screens/Businessman/owner_home_screen.dart';
import '../screens/Businessman/owner_add_screen.dart'; 
import '../screens/Businessman/owner_reserve_screen.dart';

class EasyBookApp extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyBook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => LoginScreen(),
        '/create_business': (context) => CreateBusinessScreen(),
      },
      onGenerateRoute: (settings) {
        // Verifica la ruta y los parámetros que estás pasando
        if (settings.name == '/business_reservations') {
          final businessId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => BusinessReservationsScreen(businessId: businessId),
          );
        }

        return MaterialPageRoute(
          builder: (context) => FutureBuilder<Map<String, dynamic>>(
            future: checkUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                final role = snapshot.data?['role'];
                if (role == 'owner') {
                  return OwnerHomeScreen();
                } else if (role == 'user') {
                  // return UserHomeScreen();
                }
              }

              return LoginScreen();
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
      return {'role': 'owner'}; // Cambia según la lógica de tu API
    }

    return {'role': 'guest'}; // Si no hay token o ownerId, asume que el usuario es un invitado
  }
}
