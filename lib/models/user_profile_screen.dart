// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class UserProfileScreen extends StatefulWidget {
//   final int userId; // Recibe el id del usuario

//   const UserProfileScreen({super.key, required this.userId});

//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   String? _role;
//   String? _avatarUrl;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   // Cargar el perfil del usuario
//   Future<void> _loadUserProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null || token.isEmpty) {
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('http://localhost:8000/api/user/user/${widget.userId}'), // Usamos el id recibido como parámetro
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final userData = json.decode(response.body);
//         setState(() {
//           _nameController.text = userData['name'];
//           _emailController.text = userData['email'];
//           _role = userData['role'];
//           _avatarUrl = userData['avatarUrl']; // Si tienes avatarUrl
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   // Actualizar perfil del usuario
//   Future<void> _updateUserProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null || token.isEmpty) {
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     final response = await http.put(
//       Uri.parse('http://localhost:8000/api/user/user/${widget.userId}'), // Usamos el id recibido como parámetro
//       headers: {'Authorization': 'Bearer $token'},
//       body: json.encode({
//         'name': _nameController.text,
//         'email': _emailController.text,
//         // Aquí puedes añadir 'avatarUrl' si decides permitirlo
//         // 'avatarUrl': _avatarUrl,
//       }),
//     );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Perfil actualizado con éxito')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error al actualizar el perfil')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Perfil de Usuario'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: _avatarUrl != null
//                   ? NetworkImage(_avatarUrl!)
//                   : const AssetImage('assets/default_avatar.png')
//                       as ImageProvider,
//             ),
//             TextButton(
//               onPressed: () {
//                 // Aquí puedes añadir funcionalidad para cambiar la foto de perfil
//               },
//               child: const Text('Cambiar Foto de Perfil'),
//             ),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Nombre'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 20),
//             // Mostrar el rol del usuario, solo lectura
//             TextFormField(
//               initialValue: _role ?? 'Cargando...',
//               decoration: const InputDecoration(
//                 labelText: 'Rol',
//               ),
//               enabled: false, // Deshabilitado para no permitir cambios
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _updateUserProfile,
//               child: const Text('Guardar Cambios'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
