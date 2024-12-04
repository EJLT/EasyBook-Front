import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateBusinessScreen extends StatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  _CreateBusinessScreenState createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _address = '';
  String _email = '';
  String _phone = '';
  String? _selectedCategory;

  bool _isLoading = false;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Cargar categorías
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
      print("Error al cargar categorías: $e");
    }
  }

  // Crear el negocio
  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/owner/businesses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _name,
          'address': _address,
          'email': _email,
          'phone': _phone,
          'category_name': _selectedCategory, 
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Negocio creado con éxito')),
        );
        Navigator.pop(context, true);
      } else {
        print("Error: Código de estado ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el negocio')),
        );
      }
    } catch (e) {
      print("Excepción al crear el negocio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error. Inténtalo de nuevo.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Negocio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Introduce los datos del negocio',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Negocio',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'La dirección es obligatoria'
                            : null,
                        onSaved: (value) => _address = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        validator: (value) => value == null || value.isEmpty
                            ? 'El correo electrónico es obligatorio'
                            : null,
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'El teléfono es obligatorio'
                            : null,
                        onSaved: (value) => _phone = value!,
                      ),
                      const SizedBox(height: 24),
                      // Dropdown para seleccionar categoría
                      categories.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              hint: const Text('Selecciona una categoría'),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['name'].toString(),
                                  child: Text(category['name']),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _createBusiness,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: const Text('Crear Negocio'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
