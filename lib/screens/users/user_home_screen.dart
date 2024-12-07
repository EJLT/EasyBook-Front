import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'create_reserve_screen.dart';
import 'user_reserve_screen.dart';
import 'dart:ui';

class UserHomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const UserHomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<dynamic> businesses = [];
  List<dynamic> filteredBusinesses = [];
  List<dynamic> categories = [];
  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory = 'Todos';

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
          filteredBusinesses = businesses;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/categories'),
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

  void _filterBusinesses() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredBusinesses = businesses
          .where((business) =>
              business['name'].toLowerCase().contains(query) &&
              (selectedCategory == 'Todos' ||
                  business['category_id'].toString() == selectedCategory))
          .toList();
    });
  }

  void _resetFilter() {
    setState(() {
      selectedCategory = 'Todos';
      _searchController.clear();
      filteredBusinesses = businesses;
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
        backgroundColor: const Color.fromARGB(
            0, 110, 143, 140), // Color principal de la AppBar
        elevation: 4.0, // Sombra para dar profundidad
        title: Row(
          children: [
            Image.asset(
              'assets/images/EasyBook.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8), // Espacio entre logo y texto
            const Text(
              'EasyBook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Contraste en el texto
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: 180, // Ajusta el tamaño de la barra de búsqueda
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar negocio...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Perfil de Usuario',
            onPressed: () {
              print('user_profile');
            },
          ),
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
      body: Stack(
        children: [
          // Fondo con imagen difusa
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Hotel.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Capa translúcida con desenfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Contenido principal
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Negocios disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      dropdownColor: const Color.fromARGB(0, 150, 170, 168)
                          .withOpacity(0.9),
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem(
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
                          _resetFilter();
                        } else {
                          setState(() {
                            selectedCategory = value;
                            _filterBusinesses();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBusinesses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.3), // Fondo translúcido
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            filteredBusinesses[index]['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            filteredBusinesses[index]['address'],
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          trailing: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateReserveScreen(
                                  businessId: filteredBusinesses[index]['id'],
                                  businessName: filteredBusinesses[index]
                                      ['name'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
