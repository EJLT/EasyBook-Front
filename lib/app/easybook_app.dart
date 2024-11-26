import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../screens/Businessman/owner_home_screen.dart';
import '../screens/Businessman/owner_add_screen.dart'; 
import '../screens/Businessman/owner_reserve_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/users/user_home_screen.dart'; 

class EasyBookApp extends StatelessWidget {
  const EasyBookApp({super.key});

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
        '/owner_home': (context) => OwnerHomeScreen(), 
        '/user_home': (context) => UserHomeScreen(), 
        '/register': (context) => RegisterScreen(),
      },
      onGenerateRoute: (settings) {
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
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                final role = snapshot.data?['role'];
                if (role == 'owner') {
                  return OwnerHomeScreen();
                } else if (role == 'user') {
                  return UserHomeScreen(); 
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
      return {'role': 'owner'}; 
    }

    // Si el usuario no tiene un token de propietario, lo tratamos como 'user'
    return {'role': 'user'}; 
  }
}
