import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerUpdateScreen extends StatefulWidget {
  final int businessId;
  final String currentName;
  final String currentAddress;
  final String currentPhone;
  final String currentEmail;
  final String currentCategory;
  final Function updateBusinessList; // Callback para actualizar la lista de negocios

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
      final response = await http.get(Uri.parse('http://localhost:8000/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = json.decode(response.body);
        setState(() {
          _categories = categoriesData.map((category) => category['name'] as String).toList();
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
        Uri.parse('http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "name": _nameController.text,
          "address": _addressController.text,
          "phone": _phoneController.text,
          "email": _emailController.text,
          "category_name": _selectedCategory, // Enviar la categoría seleccionada
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio actualizado con éxito.")),
        );
        widget.updateBusinessList(); // Llama al callback para actualizar la lista
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
        title: const Text("Actualizar Negocio"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Dirección"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),

              // Dropdown para seleccionar la categoría
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Categoría"),
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
                validator: (value) => value == null || value.isEmpty ? "Selecciona una categoría" : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateBusiness();
                  }
                },
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
