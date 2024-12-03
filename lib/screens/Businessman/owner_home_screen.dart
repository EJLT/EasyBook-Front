import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Businessman/owner_details_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;

  const OwnerHomeScreen({
    Key? key,
    this.onThemeChanged,
    this.currentThemeMode,
  }) : super(key: key);

  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  List<dynamic> _businesses = [];
  String ownerId = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerId();
  }

  Future<void> _loadOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ownerId = prefs.getString('ownerId') ?? '';
    });

    if (ownerId.isNotEmpty) {
      _loadBusinessData();
    }
  }

  Future<void> _loadBusinessData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/owner/businesses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> businesses = json.decode(response.body);
        setState(() {
          _businesses = businesses;
        });
      } else {
        print("Error: Código de estado ${response.statusCode}");
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Excepción al cargar los negocios: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra todos los datos almacenados
    Navigator.pushReplacementNamed(context, '/login');
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  title: const Text(
    'Panel del Propietario',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  backgroundColor: Colors.blueAccent,
  actions: [
    PopupMenuButton<ThemeMode>(
      onSelected: (themeMode) {
        if (widget.onThemeChanged != null) {
          widget.onThemeChanged!(themeMode);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: const Text('Tema Claro'),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: const Text('Tema Oscuro'),
        ),
      ],
      icon: const Icon(Icons.palette),
      tooltip: 'Cambiar Tema',
    ),
    IconButton(
      icon: const Icon(Icons.add_business), 
      tooltip: 'Añadir Negocio',
      onPressed: () {
        Navigator.pushNamed(context, '/owner_add');
      },
    ),
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Cerrar Sesión',
      onPressed: _logout,
    ),
          
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Negocios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _businesses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _businesses.length,
                      itemBuilder: (context, index) {
                        final business = _businesses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              business['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              business['address'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusinessDetailsScreen(businessId: business['id']),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
