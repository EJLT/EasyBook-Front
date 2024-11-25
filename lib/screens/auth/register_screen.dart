import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(); 

  // Método para hacer el registro
  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String passwordConfirmation = _passwordConfirmationController.text;
    final String role = _roleController.text;

    if (password != passwordConfirmation) {
      // Mostrar mensaje de error si las contraseñas no coinciden
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Las contraseñas no coinciden."),
      ));
      return;
    }

    // Realizar la solicitud de registro a la API
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role, 
      },
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, puedes navegar a otra pantalla o mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Registro exitoso."),
      ));
      // Aquí podrías redirigir al usuario al login o al home
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Si la respuesta no es exitosa, muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error al registrar. Inténtalo de nuevo."),
      ));
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easybook'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crea una cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de nombre
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Campo de email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Campo de password
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // Campo de password_confirmation
                  TextField(
                    controller: _passwordConfirmationController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // Campo de role
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Rol (user/owner/admin)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de registro
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text('Confirmar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}