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
      initialRoute: '/', // Cambia aquí si necesitas otra inicial
      routes: {
        '/': (context) => FutureBuilder<Map<String, dynamic>>(
              future: checkUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  final role = snapshot.data?['role'];
                  if (role == 'owner') return const OwnerHomeScreen();
                  if (role == 'user') return const UserHomeScreen();
                }
                return LoginScreen();
              },
            ),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/owner_add': (context) =>
            const CreateBusinessScreen(), // Añadimos esta pantalla
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/business_reservations') {
          final businessId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                BusinessReservationsScreen(businessId: businessId),
          );
        }

        // Verifica el estado del usuario antes de decidir la navegación
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
                  return const OwnerHomeScreen();
                } else if (role == 'user') {
                  return const UserHomeScreen();
                }
              }

              return LoginScreen(); // Si no hay rol, redirige al login
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (token != null && role != null) {
      return {'role': role};
    }

    return {};
  }
}
