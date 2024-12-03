import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'create_reserve_screen.dart';
import 'user_reserve_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const UserHomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  }) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<dynamic> businesses = [];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/businesses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          businesses = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Negocios disponibles'),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserReserveScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar Sesión',
          onPressed: _logout,
        ),
        IconButton(
          icon: Icon(
            widget.currentThemeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          tooltip: 'Cambiar Tema',
          onPressed: () {
            final newThemeMode = widget.currentThemeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
            widget.onThemeChanged(newThemeMode);
          },
        ),
      ],
    ),
    body: ListView.builder(
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(businesses[index]['name']),
          subtitle: Text(businesses[index]['address']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateReserveScreen(
                  businessId: businesses[index]['id'],
                  businessName: businesses[index]['name'],
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Selecciona un tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Modo Claro'),
              value: ThemeMode.light,
              groupValue: widget.currentThemeMode,
              onChanged: (mode) {
                widget.onThemeChanged(mode!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Modo Oscuro'),
              value: ThemeMode.dark,
              groupValue: widget.currentThemeMode,
              onChanged: (mode) {
                widget.onThemeChanged(mode!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Seguir sistema'),
              value: ThemeMode.system,
              groupValue: widget.currentThemeMode,
              onChanged: (mode) {
                widget.onThemeChanged(mode!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
