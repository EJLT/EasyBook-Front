import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../screens/Businessman/owner_home_screen.dart';
import '../screens/Businessman/owner_add_screen.dart';
import '../screens/Businessman/owner_reserve_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/users/user_home_screen.dart';

class EasyBookApp extends StatefulWidget {
  const EasyBookApp({super.key});

  @override
  _EasyBookAppState createState() => _EasyBookAppState();
}

class _EasyBookAppState extends State<EasyBookApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'light'; // Default to light
    setState(() {
      _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Save selected theme mode to shared preferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString('theme_mode', themeMode);
    setState(() {
      _themeMode = mode;
    });
  }

  // Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Convert ThemeMode to string
  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyBook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
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
              if (role == 'owner') {
                return OwnerHomeScreen(
                  onThemeChanged: (themeMode) => _saveThemeMode(themeMode),
                  currentThemeMode: _themeMode,
                );
              }
              if (role == 'user') {
                return UserHomeScreen(
                  onThemeChanged: (themeMode) => _saveThemeMode(themeMode),
                  currentThemeMode: _themeMode,
                );
              }
            }
            return LoginScreen();
          },
        ),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/owner_add': (context) => const CreateBusinessScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/business_reservations') {
          final businessId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                BusinessReservationsScreen(businessId: businessId),
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
                final role = snapshot.data?['role']; // Obtener el rol aquí

                if (role == 'owner') {
                  return OwnerHomeScreen(
                    onThemeChanged: (themeMode) => _saveThemeMode(themeMode),
                    currentThemeMode: _themeMode,
                  );
                }

                if (role == 'user') {
                  return UserHomeScreen(
                    onThemeChanged: (themeMode) => _saveThemeMode(themeMode),
                    currentThemeMode: _themeMode,
                  );
                }
              }

              return LoginScreen(); // Si no hay rol, redirige al login
            },
          ),
        );
      },
    );
  }

  // Check if user is logged in and retrieve their role
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
