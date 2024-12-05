import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../auth/login_screen.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // Método para hacer el registro
  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String passwordConfirmation = _passwordConfirmationController.text;
    final String role = _roleController.text;

    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['token'];
        final userRole = jsonResponse['role'];

        // Guardar el token y el rol en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', userRole);

        // Limpia los campos
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _passwordConfirmationController.clear();
        _roleController.clear();

        // Navega al login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peluqueria.jpg'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350, 
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.3), 
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), 
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Crea una cuenta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo de nombre
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Campo de email
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Campo de password
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Campo de password_confirmation
                        TextField(
                          controller: _passwordConfirmationController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Campo de role
                        TextField(
                          controller: _roleController,
                          decoration: InputDecoration(
                            labelText: 'Rol (user/owner)',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        // Botón de registro
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: const Color.fromARGB(255, 159, 162, 165), // Color de fondo
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            '¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
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
