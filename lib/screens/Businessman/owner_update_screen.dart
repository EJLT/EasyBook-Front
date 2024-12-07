import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Para usar el BackdropFilter

class OwnerUpdateScreen extends StatefulWidget {
  final int businessId;
  final String currentName;
  final String currentAddress;
  final String currentPhone;
  final String currentEmail;
  final String currentCategory;
  final Function
      updateBusinessList; // Callback para actualizar la lista de negocios

  const OwnerUpdateScreen({
    super.key,
    required this.businessId,
    required this.currentName,
    required this.currentAddress,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentCategory, // Recibe la categoría actual
    required this.updateBusinessList, // Recibe el callback
  });

  @override
  _OwnerUpdateScreenState createState() => _OwnerUpdateScreenState();
}

class _OwnerUpdateScreenState extends State<OwnerUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String? _selectedCategory; // Variable para la categoría seleccionada
  List<String> _categories = []; // Lista de categorías

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _addressController = TextEditingController(text: widget.currentAddress);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
    _selectedCategory = widget.currentCategory; // Asigna la categoría actual

    // Cargar las categorías
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = json.decode(response.body);
        setState(() {
          _categories = categoriesData
              .map((category) => category['name'] as String)
              .toList();
        });
      } else {
        print("Error al cargar las categorías: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al cargar categorías: $e");
    }
  }

  Future<void> _updateBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "name": _nameController.text,
          "address": _addressController.text,
          "phone": _phoneController.text,
          "email": _emailController.text,
          "category_name":
              _selectedCategory, // Enviar la categoría seleccionada
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio actualizado con éxito.")),
        );
        widget
            .updateBusinessList(); // Llama al callback para actualizar la lista
        Navigator.pop(context);
      } else {
        print("Error al actualizar: Código ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar el negocio.")),
        );
      }
    } catch (e) {
      print("Excepción al actualizar negocio: $e");
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/moderna.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              // Agregamos el Form para la validación
              key: _formKey,
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3), // Fondo translúcido
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 5, sigmaY: 5), // Efecto de desenfoque
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Actualizar Datos',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Campos de texto con validación
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Nombre",
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: "Dirección",
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: "Teléfono",
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Correo",
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value!.isEmpty ? "Campo requerido" : null,
                          ),
                          const SizedBox(height: 20),
                          // Dropdown para seleccionar la categoría
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Selecciona una categoría"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          // Botón de guardar cambios
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _updateBusiness();
                              }
                            },
                            child: const Text("Guardar cambios"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(251, 114, 118, 126),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              minimumSize: const Size(300, 50),
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
      ),
    );
  }
}
