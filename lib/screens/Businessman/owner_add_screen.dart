import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

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
        Uri.parse('http://localhost:8000/api/categories'),
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
        backgroundColor: const Color.fromARGB(0, 79, 98, 184),
        elevation: 4.0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/EasyBook.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'EasyBook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Fondo de imagen
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/cafetería.jpg', // Reemplaza con tu imagen
                    fit: BoxFit.cover,
                  ),
                ),
                // Fondo con opacidad
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                // Formulario de creación de negocio
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Introduce los datos del negocio',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Campo de nombre
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre del Negocio',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white70,
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'El nombre es obligatorio'
                                            : null,
                                    onSaved: (value) => _name = value!,
                                  ),
                                  const SizedBox(height: 16),
                                  // Campo de dirección
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Dirección',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white70,
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'La dirección es obligatoria'
                                            : null,
                                    onSaved: (value) => _address = value!,
                                  ),
                                  const SizedBox(height: 16),
                                  // Campo de correo
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    validator: (value) => value == null ||
                                            value.isEmpty
                                        ? 'El correo electrónico es obligatorio'
                                        : null,
                                    onSaved: (value) => _email = value!,
                                  ),
                                  const SizedBox(height: 16),
                                  // Campo de teléfono
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Teléfono',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(255, 255, 255, 0.702),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'El teléfono es obligatorio'
                                            : null,
                                    onSaved: (value) => _phone = value!,
                                  ),
                                  const SizedBox(height: 24),
                                  // Dropdown para seleccionar categoría
                                  categories.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : DropdownButtonFormField<String>(
                                          value: _selectedCategory,
                                          hint: const Text(
                                              'Selecciona una categoría'),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCategory = value;
                                            });
                                          },
                                          items: categories.map((category) {
                                            return DropdownMenuItem<String>(
                                              value:
                                                  category['name'].toString(),
                                              child: Text(category['name']),
                                            );
                                          }).toList(),
                                          decoration: const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white70,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                  const SizedBox(height: 24),
                                  // Botón de enviar
                                  ElevatedButton(
                                    onPressed: _createBusiness,
                                    child: const Text('Crear Negocio'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
