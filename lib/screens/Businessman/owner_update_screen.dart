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
  final Function updateBusinessList; // Callback para actualizar la lista de negocios

  const OwnerUpdateScreen({super.key, 
    required this.businessId,
    required this.currentName,
    required this.currentAddress,
    required this.currentPhone,
    required this.currentEmail,
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _addressController = TextEditingController(text: widget.currentAddress);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
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
