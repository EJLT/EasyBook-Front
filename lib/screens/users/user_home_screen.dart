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
  List<dynamic> filteredBusinesses = [];
  List<dynamic> categories = [];
  TextEditingController _searchController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _loadCategories();
    _searchController.addListener(_filterBusinesses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBusinesses);
    _searchController.dispose();
    super.dispose();
  }

  // Cargar los negocios
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
          filteredBusinesses = businesses; // Iniciar con todos los negocios
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Cargar las categorías
  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/categories'), // Endpoint para obtener categorías
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Filtrar los negocios por nombre y categoría
  void _filterBusinesses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredBusinesses = businesses
          .where((business) =>
              business['name'].toLowerCase().contains(query) &&  // Filtrado por nombre
              (selectedCategory == null || selectedCategory == 'Todos' || business['category_id'].toString() == selectedCategory))  // Filtrado por categoría
          .toList();
    });
  }

  // Filtrar por categoría
  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterBusinesses();
    });
  }

  // Restablecer el filtro
  void _resetFilter() {
    setState(() {
      selectedCategory = 'Todos'; // Mostrar todos los negocios
      _searchController.clear();
      filteredBusinesses = businesses; // Mostrar todos los negocios nuevamente
    });
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120.0), // Altura total del AppBar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar negocio por nombre...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Dropdown para seleccionar categoría
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCategory,
                  hint: const Text('Filtrar por categoría'),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Todos',
                      child: Text('Todos'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value == null || value == 'Todos') {
                      _resetFilter(); // Si seleccionan 'Todos', restablece el filtro
                    } else {
                      _filterByCategory(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredBusinesses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredBusinesses[index]['name']),
            subtitle: Text(filteredBusinesses[index]['address']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateReserveScreen(
                    businessId: filteredBusinesses[index]['id'],
                    businessName: filteredBusinesses[index]['name'],
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
